import RealityKit
import ARKit
import Combine
import SwiftUI

class ARViewModel: NSObject, ObservableObject {
    @Published var measuredDistance: Double?
    @Published var measurementState: MeasurementState = .ready
    @Published var isPlaneDetected: Bool = false
    
    private var startPoint: SIMD3<Float>?
    private var endPoint: SIMD3<Float>?
    private var measurementNodes: [Entity] = []
    private var lineNode: Entity?
    
    enum MeasurementState {
        case ready
        case firstPointSet
        case complete
    }
    
    func setupAR(_ arView: ARView) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        
        // Enable more accurate distance measurements
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        
        arView.session.delegate = self
        arView.session.run(configuration)
        
        // Add coaching overlay
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.addSubview(coachingOverlay)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let arView = gesture.view as? ARView else { return }
        
        let location = gesture.location(in: arView)
        
        // Perform ray-casting against detected planes
        guard let query = arView.makeRaycastQuery(from: location,
                                                allowing: .estimatedPlane,
                                                alignment: .any) else { return }
        
        guard let result = arView.session.raycast(query).first else { return }
        
        let worldPosition = result.worldTransform.columns.3
        let position = SIMD3<Float>(worldPosition.x, worldPosition.y, worldPosition.z)
        
        switch measurementState {
        case .ready:
            startPoint = position
            addMeasurementPoint(at: position, in: arView)
            measurementState = .firstPointSet
            
        case .firstPointSet:
            endPoint = position
            addMeasurementPoint(at: position, in: arView)
            updateMeasurementLine(in: arView)
            calculateDistance()
            measurementState = .complete
            
        case .complete:
            // Reset measurement
            resetMeasurement(in: arView)
        }
    }
    
    func resetMeasurement(in arView: ARView) {
        // Remove all measurement visualization
        measurementNodes.forEach { $0.removeFromParent() }
        lineNode?.removeFromParent()
        
        measurementNodes.removeAll()
        lineNode = nil
        startPoint = nil
        endPoint = nil
        measuredDistance = nil
        measurementState = .ready
    }
    
    private func addMeasurementPoint(at position: SIMD3<Float>, in arView: ARView) {
        // Create sphere to mark measurement point
        let sphereMesh = MeshResource.generateSphere(radius: 0.01)
        let sphereMaterial = SimpleMaterial(color: .green, isMetallic: false)
        let sphereEntity = ModelEntity(mesh: sphereMesh, materials: [sphereMaterial])
        
        // Create anchor for the point
        let anchor = AnchorEntity(world: position)
        anchor.addChild(sphereEntity)
        
        arView.scene.addAnchor(anchor)
        measurementNodes.append(anchor)
    }
    
    private func updateMeasurementLine(in arView: ARView) {
        guard let start = startPoint, let end = endPoint else { return }
        
        // Remove existing line if any
        lineNode?.removeFromParent()
        
        // Calculate line parameters
        let distance = simd_distance(start, end)
        let midPoint = (start + end) / 2
        
        // Create line geometry
        let thickness: Float = 0.005
        let lineMesh = MeshResource.generateBox(size: [thickness, thickness, distance])
        let lineMaterial = SimpleMaterial(color: .yellow, isMetallic: false)
        let lineEntity = ModelEntity(mesh: lineMesh, materials: [lineMaterial])
        
        // Position and orient the line
        let deltaPosition = end - start
        let normalizedDirection = simd_normalize(deltaPosition)
        
        // Calculate the rotation to align the line with the measurement points
        let defaultDirection = SIMD3<Float>(0, 0, 1) // Default forward direction
        let angle = acos(simd_dot(defaultDirection, normalizedDirection))
        let rotationAxis = simd_cross(defaultDirection, normalizedDirection)
        let rotation = simd_quaternion(angle, rotationAxis)
        
        // Create anchor for the line
        let anchor = AnchorEntity(world: midPoint)
        anchor.addChild(lineEntity)
        anchor.transform.rotation = rotation
        
        arView.scene.addAnchor(anchor)
        lineNode = anchor
    }
    
    private func calculateDistance() {
        guard let start = startPoint, let end = endPoint else { return }
        let distance = simd_distance(start, end)
        // Convert to meters and round to 2 decimal places
        measuredDistance = Double(round(distance * 100) / 100)
    }
}

extension ARViewModel: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        if !isPlaneDetected {
            if anchors.contains(where: { $0 is ARPlaneAnchor }) {
                isPlaneDetected = true
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Handle errors
        print("AR Session failed: \(error.localizedDescription)")
    }
}

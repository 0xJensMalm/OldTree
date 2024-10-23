// ARViewModel.swift
import RealityKit
import ARKit
import Combine
import SwiftUI

class ARViewModel: NSObject, ObservableObject {
    @Published var measuredDistance: Double?
    @Published var measurementState: MeasurementState = .ready
    @Published var isPlaneDetected: Bool = false
    @Published var arSessionError: String?
    
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
        // Check if device supports AR
        guard ARWorldTrackingConfiguration.isSupported else {
            arSessionError = "AR is not supported on this device"
            return
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        
        // Reset any existing session
        arView.session.pause()
        arView.scene.anchors.removeAll()
        
        // Enable more accurate distance measurements
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        
        arView.session.delegate = self
        
        // Start new session with reset options
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
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
                DispatchQueue.main.async {
                    self.isPlaneDetected = true
                }
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.arSessionError = error.localizedDescription
            print("AR Session failed: \(error)")
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        DispatchQueue.main.async {
            self.arSessionError = "AR Session was interrupted"
        }
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        DispatchQueue.main.async {
            self.arSessionError = nil
            // Reset the session
            if let configuration = session.configuration {
                session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            }
        }
    }
}

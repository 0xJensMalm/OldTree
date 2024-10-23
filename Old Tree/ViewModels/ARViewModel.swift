// ViewModels/ARViewModel.swift
import RealityKit
import ARKit

class ARViewModel: ObservableObject {
    @Published var measuredDistance: Double?
    
    func setupAR(_ arView: ARView) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        arView.session.run(configuration)
        
        // Add tap gesture for measurements
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        // Implement measurement logic here
    }
}

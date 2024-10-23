// Views/CameraView.swift

import SwiftUI
import RealityKit
import ARKit

struct ARMeasurementView: UIViewRepresentable {
    @ObservedObject var viewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        viewModel.setupAR(arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update view if needed
    }
}

struct CameraView: View {
    let selectedTree: TreeType?
    @StateObject private var arViewModel = ARViewModel()
    
    // Helper function to get the ARView
    private func getARView() -> ARView? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else { return nil }
        
        return window.rootViewController?.view as? ARView
    }
    
    var body: some View {
        ZStack {
            ARMeasurementView(viewModel: arViewModel)
                .ignoresSafeArea()
            
            VStack {
                // Measurement status and instructions
                switch arViewModel.measurementState {
                case .ready:
                    if arViewModel.isPlaneDetected {
                        InstructionView(text: "Tap to set first point")
                    } else {
                        InstructionView(text: "Move camera to detect surfaces")
                    }
                case .firstPointSet:
                    InstructionView(text: "Tap to set second point")
                case .complete:
                    if let distance = arViewModel.measuredDistance {
                        MeasurementResultView(distance: distance)
                    }
                }
                
                Spacer()
                
                // Controls
                HStack {
                    Button("Reset") {
                        if let arView = getARView() {
                            arViewModel.resetMeasurement(in: arView)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if arViewModel.measurementState == .complete {
                        NavigationLink(destination: AnalyticsView()) {
                            Text("Continue")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Measure Tree")
                    .font(.headline)
                    .foregroundColor(TreeTheme.darkGreen)
            }
        }
    }
}
struct InstructionView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.headline)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            .padding()
    }
}

struct MeasurementResultView: View {
    let distance: Double
    
    var body: some View {
        VStack {
            Text("Diameter")
                .font(.headline)
            Text(String(format: "%.2f meters", distance))
                .font(.title2)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        .padding()
    }
}

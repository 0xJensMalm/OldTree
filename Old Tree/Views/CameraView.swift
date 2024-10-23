import SwiftUI
import RealityKit
import ARKit
import AVFoundation

struct ARMeasurementView: UIViewRepresentable {
    @ObservedObject var viewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        viewModel.setupAR(arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

struct CameraView: View {
    let selectedTree: TreeType?
    @StateObject private var arViewModel = ARViewModel()
    @State private var showCameraError = false
    @State private var errorMessage = ""
    @State private var useMetric = true
    
    private func getARView() -> ARView? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else { return nil }
        
        return window.rootViewController?.view as? ARView
    }
    
    private func formatDistance(_ meters: Double) -> String {
        if useMetric {
            return String(format: "%.1f cm", meters * 100)
        } else {
            let inches = meters * 39.3701
            return String(format: "%.1f inches", inches)
        }
    }
    
    var body: some View {
        ZStack {
            ARMeasurementView(viewModel: arViewModel)
                .ignoresSafeArea()
                .onAppear {
                    checkCameraAuthorization()
                }
            
            VStack {
                // Info box at the top
                Text("To analyze tree age, measure its diameter at chest height")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.top, 8)
                    .padding(.horizontal)
                
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
                        MeasurementResultView(distance: distance, formattedDistance: formatDistance(distance))
                    }
                }
                
                Spacer()
                
                // Bottom control panel
                VStack(spacing: 12) {
                    // Unit toggle
                    Picker("", selection: $useMetric) {
                        Text("cm").tag(true)
                        Text("inch").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 120)
                    
                    // Analyze button
                    NavigationLink(destination: AnalyticsView()) {
                        Text("Analyze")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 44)
                            .background(
                                arViewModel.measurementState == .complete ?
                                Color.green : Color.gray.opacity(0.5)
                            )
                            .cornerRadius(10)
                    }
                    .disabled(arViewModel.measurementState != .complete)
                }
                .padding(.vertical, 20)
                .padding(.horizontal)
                .background(
                    Rectangle()
                        .fill(Color.black.opacity(0.7))
                        .edgesIgnoringSafeArea(.bottom)
                )
            }
        }
        .navigationBarHidden(true)
        .alert("Camera Error", isPresented: $showCameraError) {
            Button("OK", role: .cancel) {}
            Button("Open Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    errorMessage = "Camera access is required to use AR features"
                    showCameraError = true
                }
            }
        case .denied, .restricted:
            errorMessage = "Camera access is required. Please enable it in Settings."
            showCameraError = true
        @unknown default:
            errorMessage = "Unknown camera authorization status"
            showCameraError = true
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
    let formattedDistance: String
    
    var body: some View {
        VStack {
            Text("Diameter")
                .font(.headline)
            Text(formattedDistance)
                .font(.title2)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        .padding()
    }
}

#Preview {
    CameraView(selectedTree: nil)
}

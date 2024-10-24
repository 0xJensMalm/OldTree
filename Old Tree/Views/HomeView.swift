import SwiftUI
import AVFoundation

struct HomeView: View {
    @State private var isCameraAuthorized = false
    @State private var showingCameraAlert = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 60))
                .foregroundColor(TreeTheme.leafGreen)
            
            Text("Tree Tales")
                .font(.largeTitle)
                .foregroundColor(TreeTheme.darkGreen)
            
            NavigationLink(destination: SelectTreeView()) {
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                    Text("Analyze Tree")
                        .font(.title2)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(TreeTheme.darkGreen)
                .foregroundColor(.white)
                .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            .onAppear(perform: checkCameraAuthorization)
            .alert("Camera Access Required", isPresented: $showingCameraAlert) {
                Button("Go to Settings", role: .none) {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please allow camera access in Settings to measure trees.")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image("bg") // Your background image
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
    
    private func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    isCameraAuthorized = granted
                    if !granted {
                        showingCameraAlert = true
                    }
                }
            }
        case .denied, .restricted:
            isCameraAuthorized = false
            showingCameraAlert = true
        @unknown default:
            isCameraAuthorized = false
            showingCameraAlert = true
        }
    }
}

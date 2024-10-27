import SwiftUI
import AVFoundation

struct HomeView: View {
    @State private var isCameraAuthorized = false
    @State private var showingCameraAlert = false
    
    var body: some View {
        ZStack {
            // Background
            Image("bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Subtle dark overlay for readability
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // Main Content
            VStack(spacing: 40) {
                // Title Area
                VStack(spacing: 16) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.black)
                    
                    Text("Tree Tales")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // Centered Button
                NavigationLink(destination: SelectTreeView()) {
                    Text("Get Started")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 220, height: 60)
                        .background(Color.black)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
                .buttonStyle(ButtonStyles.Scale())
                
                Spacer()
            }
            .padding(.vertical, 50)
        }
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}

// Views/CameraView.swift
import SwiftUI

struct CameraView: View {
    let selectedTree: TreeType?
    
    @State private var points: [CGPoint] = []
    @State private var lineLength: CGFloat = 0
    
    var canAnalyze: Bool {
        points.count == 2
    }
    
    var body: some View {
        VStack {
            // Placeholder for camera view with measurement overlay
            GeometryReader { geometry in
                ZStack {
                    Color.black.opacity(0.8)
                        .overlay(
                            Text("Camera Placeholder")
                                .foregroundColor(.white)
                        )
                    
                    // Measurement points and line
                    ForEach(points.indices, id: \.self) { index in
                        Circle()
                            .fill(TreeTheme.leafGreen)
                            .frame(width: 20, height: 20)
                            .position(points[index])
                    }
                    
                    if points.count == 2 {
                        Path { path in
                            path.move(to: points[0])
                            path.addLine(to: points[1])
                        }
                        .stroke(TreeTheme.leafGreen, lineWidth: 2)
                        
                        // Show measurement text
                        Text(String(format: "%.1f cm", lineLength))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(TreeTheme.darkGreen)
                            .cornerRadius(8)
                            .position(
                                x: (points[0].x + points[1].x) / 2,
                                y: (points[0].y + points[1].y) / 2 - 20
                            )
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { location in
                    if points.count < 2 {
                        points.append(location)
                        if points.count == 2 {
                            // Calculate line length (this would be converted to real-world units in production)
                            let dx = points[1].x - points[0].x
                            let dy = points[1].y - points[0].y
                            lineLength = sqrt(dx * dx + dy * dy) / 2 // Arbitrary scaling for demo
                        }
                    }
                }
            }
            
            VStack(spacing: 20) {
                Text(selectedTree?.name ?? "Selected Tree")
                    .font(.headline)
                    .foregroundColor(TreeTheme.darkGreen)
                
                Text("Tap two points to measure tree diameter")
                    .foregroundColor(TreeTheme.darkGreen)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                
                HStack(spacing: 20) {
                    Button(action: resetMeasurement) {
                        Text("Reset")
                            .padding()
                            .frame(width: 120)
                            .background(TreeTheme.forestBrown)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: AnalyticsView()) {
                        Text("Analyze")
                            .padding()
                            .frame(width: 120)
                            .background(canAnalyze ? TreeTheme.leafGreen : TreeTheme.leafGreen.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!canAnalyze)
                }
            }
            .padding()
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
    
    private func resetMeasurement() {
        points.removeAll()
        lineLength = 0
    }
}

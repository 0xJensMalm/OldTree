// Views/SelectTreeView.swift
import SwiftUI
import Foundation

struct SelectTreeView: View {
    @State private var selectedTree: TreeType?
    
    // Define grid layout with adjusted spacing
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            // Background image
            Image("bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Semi-transparent overlay for better readability
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                Text("Which tree do you have in front of you?")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Tree grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(TreeType.types) { tree in
                            TreeSelectionCard(
                                tree: tree,
                                isSelected: selectedTree?.id == tree.id,
                                action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedTree = tree
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Continue button
                NavigationLink(destination: CameraView(selectedTree: selectedTree)) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Analyze Tree Age")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedTree != nil ? TreeTheme.darkGreen : TreeTheme.darkGreen.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, y: 2)
                }
                .disabled(selectedTree == nil)
                .padding(.horizontal, 40)
                .padding(.bottom)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Select Tree Type")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
}

struct TreeSelectionCard: View {
    let tree: TreeType
    let isSelected: Bool
    let action: () -> Void
    
    private let iconSize: CGFloat = 44 // Consistent icon container size
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Tree icon and name header
                HStack(spacing: 12) {
                    // Icon container
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: iconSize, height: iconSize)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, y: 1)
                        
                        Image(tree.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: iconSize * 0.6, height: iconSize * 0.6)
                    }
                    
                    Text(tree.name)
                        .font(.headline)
                        .foregroundColor(TreeTheme.darkGreen)
                }
                
                // Description
                Text(tree.description)
                    .font(.subheadline)
                    .foregroundColor(TreeTheme.darkGreen.opacity(0.8))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Age indicator
                Text("Can be up to \(tree.maxAge) years")
                    .font(.caption)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(
                        Capsule()
                            .fill(TreeTheme.leafGreen.opacity(0.2))
                    )
                    .foregroundColor(TreeTheme.darkGreen)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? TreeTheme.darkGreen : Color.clear, lineWidth: 3) // Increased from 2 to 3
            )
            .shadow(
                color: Color.black.opacity(isSelected ? 0.15 : 0.1),
                radius: isSelected ? 8 : 5,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    NavigationView {
        SelectTreeView()
    }
}

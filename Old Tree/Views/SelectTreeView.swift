import SwiftUI

struct SelectTreeView: View {
    @State private var selectedTree: TreeType?
    
    // Define grid layout
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Which tree do you have in front of you?")
                .font(.title2)
                .foregroundColor(TreeTheme.darkGreen)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top)
            
            LazyVGrid(columns: columns, spacing: 16) {
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
            
            Spacer()
            
            NavigationLink(destination: CameraView(selectedTree: selectedTree)) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Continue to Measurement")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(selectedTree != nil ? TreeTheme.darkGreen : TreeTheme.darkGreen.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(15)
            }
            .disabled(selectedTree == nil)
            .padding(.horizontal, 40)
            .padding(.bottom)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Select Tree Type")
                    .font(.headline)
                    .foregroundColor(TreeTheme.darkGreen)
            }
        }
    }
}

struct TreeSelectionCard: View {
    let tree: TreeType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(isSelected ? TreeTheme.leafGreen : TreeTheme.darkGreen)
                        .frame(width: 32, height: 32)
                        .overlay {
                            Image(systemName: tree.icon)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                    
                    Text(tree.name)
                        .font(.headline)
                }
                
                Text(tree.description)
                    .font(.caption)
                    .foregroundColor(TreeTheme.darkGreen.opacity(0.8))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Can be up to \(tree.maxAge) years")
                    .font(.caption2)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 6)
                    .background(
                        Capsule()
                            .fill(TreeTheme.leafGreen.opacity(0.2))
                    )
                    .foregroundColor(TreeTheme.darkGreen)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? TreeTheme.darkGreen : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

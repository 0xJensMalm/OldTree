// Views/SelectTreeView.swift
import SwiftUI

struct SelectTreeView: View {
    @State private var selectedTree: TreeType?
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Which tree do you have in front of you?")
                .font(.title2)
                .foregroundColor(TreeTheme.darkGreen)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(TreeType.types) { tree in
                    TreeSelectionCard(
                        tree: tree,
                        isSelected: selectedTree?.id == tree.id,
                        action: {
                            selectedTree = tree
                        }
                    )
                }
            }
            .padding()
            
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
            VStack(spacing: 15) {
                Image(systemName: tree.icon)
                    .font(.system(size: 40))
                Text(tree.name)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? TreeTheme.leafGreen : Color.white)
            .foregroundColor(isSelected ? .white : TreeTheme.darkGreen)
            .cornerRadius(15)
            .shadow(radius: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? TreeTheme.darkGreen : Color.clear, lineWidth: 2)
            )
        }
    }
}

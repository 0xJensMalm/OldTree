// Views/HistoryView.swift
import SwiftUI

struct HistoryView: View {
    var body: some View {
        VStack {
            Text("Interactive History Timeline")
                .font(.title2)
                .foregroundColor(TreeTheme.darkGreen)
            
            Text("Coming Soon!")
                .foregroundColor(TreeTheme.forestBrown)
                .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Historical Context")
                    .font(.headline)
                    .foregroundColor(TreeTheme.darkGreen)
            }
        }
    }
}

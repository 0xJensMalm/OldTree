// Views/HistoryView.swift
import SwiftUI

struct HistoryView: View {
    let estimatedAge: Int
    let birthYear: Int
    
    var body: some View {
        TimelineView(estimatedAge: estimatedAge, birthYear: birthYear)
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

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HistoryView(estimatedAge: 50, birthYear: 1974)
        }
    }
}

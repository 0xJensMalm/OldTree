// Views/AnalyticsView.swift
import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        VStack(spacing: 25) {
            VStack(alignment: .leading, spacing: 15) {
                InfoCard(title: "Estimated Age", value: "120 years")
                InfoCard(title: "Species", value: "Oak")
                InfoCard(title: "Fun Fact", value: "This tree has lived through both World Wars!")
            }
            .padding()
            
            NavigationLink(destination: HistoryView()) {
                Text("Explore Historical Context")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(TreeTheme.darkGreen)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Tree Analysis")
                    .font(.headline)
                    .foregroundColor(TreeTheme.darkGreen)
            }
        }
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(TreeTheme.forestBrown)
            Text(value)
                .font(.title3)
                .foregroundColor(TreeTheme.darkGreen)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// Views/HomeView.swift
import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 60))
                .foregroundColor(TreeTheme.leafGreen)
            
            Text("Old Tree")
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.95))
    }
}

import SwiftUI
import Foundation

struct TreeType: Identifiable {
    let id = UUID()
    let name: String
    let icon: String // SF Symbol name
    let description: String
    let maxAge: Int
    let growthFactor: Double
    
    static let types = [
        TreeType(
            name: "Spruce",
            icon: "leaf.arrow.triangle.circlepath",
            description: "Fast-growing evergreen with straight trunk and cone-shaped crown",
            maxAge: 350,
            growthFactor: 0.7
        ),
        TreeType(
            name: "Pine",
            icon: "leaf.circle",
            description: "Tall evergreen with distinctive bark and needle-like leaves",
            maxAge: 450,
            growthFactor: 0.6
        ),
        TreeType(
            name: "Birch",
            icon: "leaf.fill",
            description: "Graceful deciduous tree with distinctive white bark",
            maxAge: 200,
            growthFactor: 0.5
        ),
        TreeType(
            name: "Oak",
            icon: "leaf.circle.fill",
            description: "Majestic hardwood known for its strong, dense wood",
            maxAge: 1000,
            growthFactor: 0.8
        )
    ]
}

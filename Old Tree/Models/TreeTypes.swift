// Models/TreeTypes.swift
import SwiftUI
import Foundation

struct TreeType: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String // Changed from icon to imageName
    let description: String
    let maxAge: Int
    let growthFactor: Double
    
    static let types = [
        TreeType(
            name: "Spruce",
            imageName: "spruce", // Changed to use custom image
            description: "Fast-growing evergreen with straight trunk and cone-shaped crown",
            maxAge: 350,
            growthFactor: 0.7
        ),
        TreeType(
            name: "Pine",
            imageName: "pine", // Changed to use custom image
            description: "Tall evergreen with distinctive bark and needle-like leaves",
            maxAge: 450,
            growthFactor: 0.6
        ),
        TreeType(
            name: "Birch",
            imageName: "birch", // Changed to use custom image
            description: "Graceful deciduous tree with distinctive white bark",
            maxAge: 200,
            growthFactor: 0.5
        ),
        TreeType(
            name: "Oak",
            imageName: "oak", // Changed to use custom image
            description: "Majestic hardwood known for its strong, dense wood",
            maxAge: 1000,
            growthFactor: 0.8
        )
    ]
}

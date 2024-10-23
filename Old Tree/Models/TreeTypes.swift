// Models/TreeType.swift
import SwiftUI

struct TreeType: Identifiable {
    let id = UUID()
    let name: String
    let icon: String // SF Symbol name
    let growthFactor: Double
    
    static let types = [
        TreeType(name: "Spruce", icon: "leaf.fill", growthFactor: 0.7),
        TreeType(name: "Pine", icon: "leaf.fill", growthFactor: 0.6),
        TreeType(name: "Birch", icon: "leaf.fill", growthFactor: 0.5),
        TreeType(name: "Oak", icon: "leaf.fill", growthFactor: 0.8)
    ]
}

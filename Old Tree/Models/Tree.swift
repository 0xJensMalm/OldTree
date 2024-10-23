import Foundation

struct Tree: Identifiable {
    let id = UUID()
    var species: TreeSpecies
    var diameter: Double
    var estimatedAge: Int
}

enum TreeSpecies: String, CaseIterable {
    case birch = "Birch"
    case oak = "Oak"
    case pine = "Pine"
    case maple = "Maple"
    
    var growthFactor: Double {
        switch self {
            case .birch: return 0.5
            case .oak: return 0.8
            case .pine: return 0.6
            case .maple: return 0.7
        }
    }
}

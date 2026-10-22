import Foundation

enum ActivityEnergy: String, Codable, CaseIterable, Identifiable {
    case low
    case medium
    case high

    var id: String { rawValue }

    var label: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

enum ActivityCategory: String, Codable, CaseIterable, Identifiable {
    case chores
    case movement
    case entertainment
    case personal
    case learning
    case focus

    var id: String { rawValue }

    var label: String {
        switch self {
        case .chores: return "Chores"
        case .movement: return "Movement"
        case .entertainment: return "Fun"
        case .personal: return "Personal"
        case .learning: return "Learning"
        case .focus: return "Focus"
        }
    }
}

struct Activity: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var durationMinutes: Int
    var energy: ActivityEnergy
    var category: ActivityCategory
    var usesScreen: Bool
    var allowedAtNight: Bool

    init(
        id: UUID = UUID(),
        title: String,
        durationMinutes: Int,
        energy: ActivityEnergy,
        category: ActivityCategory,
        usesScreen: Bool,
        allowedAtNight: Bool
    ) {
        self.id = id
        self.title = title
        self.durationMinutes = durationMinutes
        self.energy = energy
        self.category = category
        self.usesScreen = usesScreen
        self.allowedAtNight = allowedAtNight
    }
}

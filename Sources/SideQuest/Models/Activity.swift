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
    var cooldownDays: Int?
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        durationMinutes: Int,
        energy: ActivityEnergy,
        category: ActivityCategory,
        usesScreen: Bool,
        allowedAtNight: Bool,
        cooldownDays: Int? = nil,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.durationMinutes = durationMinutes
        self.energy = energy
        self.category = category
        self.usesScreen = usesScreen
        self.allowedAtNight = allowedAtNight
        self.cooldownDays = cooldownDays
        self.completedAt = completedAt
    }

    func availableAgainAt(calendar: Calendar = .current) -> Date? {
        guard
            let cooldownDays,
            cooldownDays > 0,
            let completedAt
        else {
            return nil
        }

        return calendar.date(byAdding: .day, value: cooldownDays, to: completedAt)
    }

    func isCoolingDown(at date: Date, calendar: Calendar = .current) -> Bool {
        guard let availableAgainAt = availableAgainAt(calendar: calendar) else {
            return false
        }
        return date < availableAgainAt
    }
}

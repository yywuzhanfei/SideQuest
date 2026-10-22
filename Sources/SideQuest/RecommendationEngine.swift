import Foundation

struct ActivityFilters: Equatable {
    var maxDuration: Int?
    var lowEnergyOnly = false
    var noScreenOnly = false
    var funOnly = false
}

enum RecommendationEngine {
    static func filtered(
        activities: [Activity],
        filters: ActivityFilters,
        nightMode: Bool,
        now: Date = Date()
    ) -> [Activity] {
        activities.filter { activity in
            if activity.isCoolingDown(at: now) { return false }
            if nightMode && !activity.allowedAtNight { return false }
            if let maxDuration = filters.maxDuration,
               activity.durationMinutes > maxDuration { return false }
            if filters.lowEnergyOnly && activity.energy != .low { return false }
            if filters.noScreenOnly && activity.usesScreen { return false }
            if filters.funOnly && activity.category != .entertainment { return false }
            return true
        }
    }

    static func pick(
        activities: [Activity],
        filters: ActivityFilters,
        nightMode: Bool,
        now: Date = Date()
    ) -> Activity? {
        filtered(
            activities: activities,
            filters: filters,
            nightMode: nightMode,
            now: now
        ).randomElement()
    }
}

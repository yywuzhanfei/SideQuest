import Combine
import Foundation

@MainActor
final class ActivityStore: ObservableObject {
    @Published private(set) var activities: [Activity] = []

    private let defaults: UserDefaults
    private let storageKey = "sidequest.activities.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func add(_ activity: Activity) {
        activities.append(activity)
        persist()
    }

    func remove(_ activity: Activity) {
        activities.removeAll { $0.id == activity.id }
        persist()
    }

    func resetToDefaults() {
        activities = Self.defaultActivities
        persist()
    }

    private func load() {
        guard
            let data = defaults.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([Activity].self, from: data)
        else {
            activities = Self.defaultActivities
            persist()
            return
        }

        activities = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(activities) else { return }
        defaults.set(data, forKey: storageKey)
    }

    static let defaultActivities: [Activity] = [
        Activity(title: "Take a shower", durationMinutes: 15, energy: .low, category: .personal, usesScreen: false, allowedAtNight: true),
        Activity(title: "Walk outside", durationMinutes: 20, energy: .medium, category: .movement, usesScreen: false, allowedAtNight: true),
        Activity(title: "Stretch", durationMinutes: 10, energy: .low, category: .movement, usesScreen: false, allowedAtNight: true),
        Activity(title: "Tidy the desk", durationMinutes: 10, energy: .low, category: .chores, usesScreen: false, allowedAtNight: true),
        Activity(title: "Take out the trash", durationMinutes: 5, energy: .low, category: .chores, usesScreen: false, allowedAtNight: true),
        Activity(title: "Prep tomorrow's clothes", durationMinutes: 5, energy: .low, category: .personal, usesScreen: false, allowedAtNight: true),
        Activity(title: "Play with the cat", durationMinutes: 15, energy: .low, category: .personal, usesScreen: false, allowedAtNight: true),
        Activity(title: "Listen to a podcast", durationMinutes: 30, energy: .low, category: .entertainment, usesScreen: false, allowedAtNight: true),
        Activity(title: "Watch one episode", durationMinutes: 30, energy: .low, category: .entertainment, usesScreen: true, allowedAtNight: true),
        Activity(title: "Read a book", durationMinutes: 30, energy: .low, category: .learning, usesScreen: false, allowedAtNight: true),
        Activity(title: "Practice spoken English", durationMinutes: 20, energy: .medium, category: .learning, usesScreen: true, allowedAtNight: true),
        Activity(title: "Go to the gym", durationMinutes: 60, energy: .high, category: .movement, usesScreen: false, allowedAtNight: true),
        Activity(title: "Coding side project", durationMinutes: 60, energy: .high, category: .focus, usesScreen: true, allowedAtNight: false),
        Activity(title: "Interview prep", durationMinutes: 45, energy: .high, category: .focus, usesScreen: true, allowedAtNight: false),
        Activity(title: "Investment research", durationMinutes: 45, energy: .high, category: .focus, usesScreen: true, allowedAtNight: false),
        Activity(title: "Work on a work problem", durationMinutes: 45, energy: .high, category: .focus, usesScreen: true, allowedAtNight: false)
    ]
}

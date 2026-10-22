import Combine
import Foundation

@MainActor
final class ActivityStore: ObservableObject {
    @Published private(set) var activities: [Activity] = []

    private let defaults: UserDefaults
    private let storageKey = "sidequest.activities.v2"

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

    func markDone(_ activity: Activity, at date: Date = Date()) {
        guard let index = activities.firstIndex(where: { $0.id == activity.id }) else { return }
        activities[index].completedAt = date
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
        Activity(title: "腘绳肌 + 臀中肌放松", durationMinutes: 15, energy: .low, category: .movement, usesScreen: false, allowedAtNight: true),
        Activity(title: "收拾桌面", durationMinutes: 10, energy: .low, category: .chores, usesScreen: false, allowedAtNight: true),
        Activity(title: "倒垃圾", durationMinutes: 5, energy: .low, category: .chores, usesScreen: false, allowedAtNight: true, cooldownDays: 1),
        Activity(title: "洗 / 收一轮衣服", durationMinutes: 15, energy: .low, category: .chores, usesScreen: false, allowedAtNight: true, cooldownDays: 4),
        Activity(title: "看书", durationMinutes: 30, energy: .low, category: .learning, usesScreen: false, allowedAtNight: true),
        Activity(title: "看一集剧", durationMinutes: 60, energy: .low, category: .entertainment, usesScreen: true, allowedAtNight: true),
        Activity(title: "看一部电影", durationMinutes: 120, energy: .low, category: .entertainment, usesScreen: true, allowedAtNight: true),
        Activity(title: "整理照片", durationMinutes: 15, energy: .low, category: .personal, usesScreen: true, allowedAtNight: true),
        Activity(title: "Coding side project", durationMinutes: 60, energy: .high, category: .focus, usesScreen: true, allowedAtNight: false),
        Activity(title: "面试准备", durationMinutes: 45, energy: .high, category: .focus, usesScreen: true, allowedAtNight: false),
        Activity(title: "投资研究", durationMinutes: 45, energy: .high, category: .focus, usesScreen: true, allowedAtNight: false),
        Activity(title: "给猫梳毛", durationMinutes: 5, energy: .low, category: .personal, usesScreen: false, allowedAtNight: true, cooldownDays: 3)
    ]
}

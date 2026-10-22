import XCTest
@testable import SideQuest

@MainActor
final class ActivityStoreTests: XCTestCase {
    func testCompletionPersistsAcrossReload() {
        let suiteName = "SideQuestTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Could not create isolated UserDefaults suite")
            return
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.removePersistentDomain(forName: suiteName)

        let store = ActivityStore(defaults: defaults)
        let quest = Activity(
            title: "Wash bedsheets",
            durationMinutes: 20,
            energy: .low,
            category: .chores,
            usesScreen: false,
            allowedAtNight: true,
            cooldownDays: 7
        )
        store.add(quest)

        let completedAt = Date(timeIntervalSince1970: 1_800_000_000)
        store.markDone(quest, at: completedAt)

        let reloadedStore = ActivityStore(defaults: defaults)
        let reloadedQuest = reloadedStore.activities.first(where: { $0.id == quest.id })

        XCTAssertEqual(reloadedQuest?.completedAt, completedAt)
        XCTAssertEqual(reloadedQuest?.cooldownDays, 7)
    }

    func testDefaultQuestCooldowns() {
        let defaults = ActivityStore.defaultActivities

        XCTAssertEqual(defaults.first(where: { $0.title == "倒垃圾" })?.cooldownDays, 1)
        XCTAssertEqual(defaults.first(where: { $0.title == "洗 / 收一轮衣服" })?.cooldownDays, 4)
        XCTAssertEqual(defaults.first(where: { $0.title == "给猫梳毛" })?.cooldownDays, 3)
    }
}

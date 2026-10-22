import XCTest
@testable import SideQuest

final class RecommendationEngineTests: XCTestCase {
    private let nightSafe = Activity(
        title: "Stretch",
        durationMinutes: 10,
        energy: .low,
        category: .movement,
        usesScreen: false,
        allowedAtNight: true
    )

    private let focusTask = Activity(
        title: "Coding",
        durationMinutes: 60,
        energy: .high,
        category: .focus,
        usesScreen: true,
        allowedAtNight: false
    )

    func testNightModeHidesHighFocusActivity() {
        let result = RecommendationEngine.filtered(
            activities: [nightSafe, focusTask],
            filters: ActivityFilters(),
            nightMode: true
        )

        XCTAssertEqual(result, [nightSafe])
    }

    func testDurationFilter() {
        var filters = ActivityFilters()
        filters.maxDuration = 15

        let result = RecommendationEngine.filtered(
            activities: [nightSafe, focusTask],
            filters: filters,
            nightMode: false
        )

        XCTAssertEqual(result, [nightSafe])
    }

    func testNoScreenFilter() {
        var filters = ActivityFilters()
        filters.noScreenOnly = true

        let result = RecommendationEngine.filtered(
            activities: [nightSafe, focusTask],
            filters: filters,
            nightMode: false
        )

        XCTAssertEqual(result, [nightSafe])
    }

    func testCooldownHidesCompletedQuestUntilExpiry() {
        let completedAt = Date(timeIntervalSince1970: 1_800_000_000)
        let coolingQuest = Activity(
            title: "Brush the cat",
            durationMinutes: 5,
            energy: .low,
            category: .personal,
            usesScreen: false,
            allowedAtNight: true,
            cooldownDays: 3,
            completedAt: completedAt
        )

        let twoDaysLater = Calendar.current.date(byAdding: .day, value: 2, to: completedAt)!
        let result = RecommendationEngine.filtered(
            activities: [coolingQuest, nightSafe],
            filters: ActivityFilters(),
            nightMode: false,
            now: twoDaysLater
        )

        XCTAssertEqual(result, [nightSafe])
    }

    func testCooldownBecomesEligibleAtBoundary() {
        let completedAt = Date(timeIntervalSince1970: 1_800_000_000)
        let coolingQuest = Activity(
            title: "Take out the trash",
            durationMinutes: 5,
            energy: .low,
            category: .chores,
            usesScreen: false,
            allowedAtNight: true,
            cooldownDays: 1,
            completedAt: completedAt
        )
        let availableAt = Calendar.current.date(byAdding: .day, value: 1, to: completedAt)!

        let result = RecommendationEngine.filtered(
            activities: [coolingQuest],
            filters: ActivityFilters(),
            nightMode: false,
            now: availableAt
        )

        XCTAssertEqual(result, [coolingQuest])
    }

    func testQuestWithoutCooldownStaysEligibleAfterDone() {
        var completedQuest = nightSafe
        completedQuest.completedAt = Date(timeIntervalSince1970: 1_800_000_000)

        let result = RecommendationEngine.filtered(
            activities: [completedQuest],
            filters: ActivityFilters(),
            nightMode: false,
            now: Date(timeIntervalSince1970: 1_800_000_100)
        )

        XCTAssertEqual(result, [completedQuest])
    }
}

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
}

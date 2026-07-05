import XCTest
@testable import Interval_Timer

final class TrainingInsightsTests: XCTestCase {
    func testTodaySummaryUsesOnlyTodayRecordsAndComputesCurrentStreak() {
        let calendar = makeCalendar()
        let now = makeDate(year: 2026, month: 7, day: 9, hour: 12, calendar: calendar)
        let records = [
            makeRecord(year: 2026, month: 7, day: 9, duration: 600, calendar: calendar),
            makeRecord(year: 2026, month: 7, day: 9, duration: 300, calendar: calendar),
            makeRecord(year: 2026, month: 7, day: 8, duration: 450, calendar: calendar),
            makeRecord(year: 2026, month: 7, day: 7, duration: 200, calendar: calendar),
            makeRecord(year: 2026, month: 7, day: 5, duration: 120, calendar: calendar)
        ]

        let summary = TodayTrainingSummary(records: records, calendar: calendar, now: now)

        XCTAssertEqual(summary.sessionCount, 2)
        XCTAssertEqual(summary.totalDuration, 900)
        XCTAssertEqual(summary.currentStreakDays, 3)
    }

    func testWeeklySummaryBuildsMondayFirstDurationsAndTotalsFromRecords() {
        let calendar = makeCalendar()
        let now = makeDate(year: 2026, month: 7, day: 9, hour: 12, calendar: calendar)
        let monday = calendar.startOfWeek(containing: now)
        let wednesday = calendar.date(byAdding: .day, value: 2, to: monday)!
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday)!
        let priorWeek = calendar.date(byAdding: .day, value: -2, to: monday)!

        let records = [
            makeRecord(on: monday, duration: 600),
            makeRecord(on: wednesday, duration: 300),
            makeRecord(on: sunday, duration: 900),
            makeRecord(on: priorWeek, duration: 1200)
        ]

        let summary = WeeklyTrainingSummary(records: records, calendar: calendar, now: now)

        XCTAssertEqual(summary.sessionCount, 3)
        XCTAssertEqual(summary.totalDuration, 1800)
        XCTAssertEqual(summary.currentStreakDays, 1)
        XCTAssertEqual(summary.dailyDurations.map(\.weekdayLabel), ["一", "二", "三", "四", "五", "六", "日"])
        XCTAssertEqual(summary.dailyDurations.map(\.durationSeconds), [600, 0, 300, 0, 0, 0, 900])
    }

    private func makeCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func makeDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        calendar: Calendar
    ) -> Date {
        calendar.date(
            from: DateComponents(
                timeZone: calendar.timeZone,
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute
            )
        )!
    }

    private func makeRecord(
        year: Int,
        month: Int,
        day: Int,
        duration: Int,
        calendar: Calendar
    ) -> TrainingRecord {
        makeRecord(on: makeDate(year: year, month: month, day: day, hour: 9, calendar: calendar), duration: duration)
    }

    private func makeRecord(on date: Date, duration: Int) -> TrainingRecord {
        TrainingRecord(
            programId: UUID(),
            programName: "Test",
            date: date,
            totalDuration: duration,
            completedRounds: 4,
            totalWorkDuration: max(duration - 60, 0)
        )
    }
}

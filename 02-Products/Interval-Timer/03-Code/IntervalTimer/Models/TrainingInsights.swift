import Foundation

extension Calendar {
    func startOfWeek(containing date: Date) -> Date {
        let day = startOfDay(for: date)
        let weekday = component(.weekday, from: day)
        let daysFromMonday = (weekday + 5) % 7
        return self.date(byAdding: .day, value: -daysFromMonday, to: day) ?? day
    }
}

struct TodayTrainingSummary: Equatable {
    let sessionCount: Int
    let totalDuration: Int
    let currentStreakDays: Int

    init(records: [TrainingRecord], calendar: Calendar, now: Date) {
        let today = calendar.startOfDay(for: now)
        let todaysRecords = records.filter { calendar.isDate($0.date, inSameDayAs: today) }

        sessionCount = todaysRecords.count
        totalDuration = todaysRecords.reduce(0) { $0 + $1.totalDuration }
        currentStreakDays = TrainingStreakCalculator.currentStreakDays(records: records, calendar: calendar)
    }
}

struct WeeklyTrainingSummary: Equatable {
    let sessionCount: Int
    let totalDuration: Int
    let currentStreakDays: Int
    let dailyDurations: [WeeklyTrainingDay]

    init(
        records: [TrainingRecord],
        calendar: Calendar,
        now: Date,
        preferredLanguages: [String] = Locale.preferredLanguages
    ) {
        let weekStart = calendar.startOfWeek(containing: now)
        let weekDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? now
        let weeklyRecords = records.filter { $0.date >= weekStart && $0.date < weekEnd }

        sessionCount = weeklyRecords.count
        totalDuration = weeklyRecords.reduce(0) { $0 + $1.totalDuration }
        currentStreakDays = TrainingStreakCalculator.currentStreakDays(records: records, calendar: calendar)

        let weekdayLabels = AppLocalization.weekdaySymbolsMondayFirst(preferredLanguages: preferredLanguages)

        dailyDurations = zip(weekDays, weekdayLabels).map { day, label in
            let duration = weeklyRecords
                .filter { calendar.isDate($0.date, inSameDayAs: day) }
                .reduce(0) { $0 + $1.totalDuration }
            return WeeklyTrainingDay(weekdayLabel: label, durationSeconds: duration, date: day)
        }
    }
}

struct WeeklyTrainingDay: Identifiable, Equatable {
    let weekdayLabel: String
    let durationSeconds: Int
    let date: Date

    var id: Date { date }
    var durationMinutes: Int {
        if durationSeconds == 0 {
            return 0
        }
        return max(1, Int(ceil(Double(durationSeconds) / 60.0)))
    }
}

private enum TrainingStreakCalculator {
    static func currentStreakDays(records: [TrainingRecord], calendar: Calendar) -> Int {
        let days = Set(records.map { calendar.startOfDay(for: $0.date) })
        guard var cursor = days.max() else { return 0 }

        var streak = 0
        while days.contains(cursor) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }
            cursor = previousDay
        }

        return streak
    }
}

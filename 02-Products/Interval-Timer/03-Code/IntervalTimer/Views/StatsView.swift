import Charts
import SwiftData
import SwiftUI

struct StatsView: View {
    @Query(sort: \TrainingRecord.date, order: .reverse) private var trainingRecords: [TrainingRecord]

    init() {}

    private var weeklySummary: WeeklyTrainingSummary {
        WeeklyTrainingSummary(records: trainingRecords, calendar: .current, now: Date())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundDeep
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // 本周概览
                        weeklyOverviewSection
                        
                        // 训练趋势
                        trendChartSection
                        
                        // 训练历史
                        historySection
                    }
                    .padding(.vertical, Spacing.md)
                }
            }
            .navigationBarTitle(AppLocalization.text("stats.title"), displayMode: .large)
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - 本周概览
    private var weeklyOverviewSection: some View {
        VStack(spacing: Spacing.md) {
            Text(AppLocalization.text("stats.weekly_overview"))
                .font(.appSubtitle)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.md)
            
            VStack(spacing: Spacing.sm) {
                HStack {
                    StatItem(
                        icon: "🔥",
                        title: AppLocalization.text("stats.label.sessions"),
                        value: AppTextFormatters.sessionCount(weeklySummary.sessionCount)
                    )
                    Spacer()
                    StatItem(
                        icon: "⏱️",
                        title: AppLocalization.text("stats.label.duration"),
                        value: AppTextFormatters.overviewDuration(weeklySummary.totalDuration)
                    )
                }
                
                HStack {
                    StatItem(
                        icon: "📅",
                        title: AppLocalization.text("stats.label.streak"),
                        value: AppTextFormatters.streakDays(weeklySummary.currentStreakDays)
                    )
                    Spacer()
                    Spacer()
                }
            }
            .padding(Spacing.md)
            .background(Color.backgroundLight)
            .cornerRadius(CornerRadius.medium)
            .padding(.horizontal, Spacing.md)
        }
    }
    
    // MARK: - 训练趋势
    private var trendChartSection: some View {
        VStack(spacing: Spacing.md) {
            Text(AppLocalization.text("stats.training_trend"))
                .font(.appSubtitle)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.md)
            
            Chart(weeklySummary.dailyDurations) { item in
                BarMark(
                    x: .value(AppLocalization.text("stats.chart.weekday"), item.weekdayLabel),
                    y: .value(AppLocalization.text("stats.chart.duration"), item.durationMinutes)
                )
                .foregroundStyle(LinearGradient.primaryGradient)
                .cornerRadius(CornerRadius.small)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 180)
            .padding(Spacing.md)
            .background(Color.backgroundLight)
            .cornerRadius(CornerRadius.medium)
            .padding(.horizontal, Spacing.md)
        }
    }
    
    // MARK: - 训练历史
    private var historySection: some View {
        VStack(spacing: Spacing.md) {
            Text(AppLocalization.text("stats.history"))
                .font(.appSubtitle)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.md)

            if trainingRecords.isEmpty {
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.system(size: 42))
                        .foregroundColor(.neonBlue)

                    Text(AppLocalization.text("stats.no_records_title"))
                        .font(.appBody)
                        .foregroundColor(.textPrimary)

                    Text(AppLocalization.text("stats.no_records_message"))
                        .font(.appSmall)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)
                }
                .padding(Spacing.md)
                .background(Color.backgroundLight)
                .cornerRadius(CornerRadius.medium)
                .padding(.horizontal, Spacing.md)
            } else {
                VStack(spacing: Spacing.sm) {
                    ForEach(Array(trainingRecords.prefix(20))) { record in
                        TrainingRecordRow(record: record)
                    }
                }
            }
        }
    }
}

// MARK: - 统计项
struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Text(icon)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.appBody)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text(title)
                    .font(.appSmall)
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 训练记录行
struct TrainingRecordRow: View {
    let record: TrainingRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(formatDate(record.date))
                    .font(.appSmall)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Text(Program.localizedName(for: record.programId, fallbackName: record.programName))
                    .font(.appBody)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
            }
            
            HStack {
                Text(AppTextFormatters.rounds(record.completedRounds))
                    .font(.appSmall)
                    .foregroundColor(.neonBlue)
                
                Text("·")
                    .foregroundColor(.textDisabled)
                
                Text(AppLocalization.format("stats.record_duration", formatDuration(record.totalDuration) as NSString))
                    .font(.appSmall)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(Spacing.sm)
        .background(Color.backgroundLight)
        .cornerRadius(CornerRadius.small)
        .padding(.horizontal, Spacing.md)
    }
    
    private func formatDate(_ date: Date) -> String {
        AppTextFormatters.localizedDate(date)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        AppTextFormatters.recordDuration(seconds)
    }
}

#Preview {
    StatsView()
}

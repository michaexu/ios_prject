import Charts
import SwiftData
import SwiftUI

struct StatsView: View {
    @Query(sort: \TrainingRecord.date, order: .reverse) private var trainingRecords: [TrainingRecord]

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
            .navigationBarTitle("训练统计", displayMode: .large)
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - 本周概览
    private var weeklyOverviewSection: some View {
        VStack(spacing: Spacing.md) {
            Text("本周概览")
                .font(.appSubtitle)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.md)
            
            VStack(spacing: Spacing.sm) {
                HStack {
                    StatItem(icon: "🔥", title: "训练次数", value: "\(weeklySummary.sessionCount) 次")
                    Spacer()
                    StatItem(icon: "⏱️", title: "总时长", value: formatDuration(weeklySummary.totalDuration))
                }
                
                HStack {
                    StatItem(icon: "📅", title: "连续天数", value: "\(weeklySummary.currentStreakDays) 天")
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
            Text("训练趋势")
                .font(.appSubtitle)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.md)
            
            Chart(weeklySummary.dailyDurations) { item in
                BarMark(
                    x: .value("星期", item.weekdayLabel),
                    y: .value("时长", item.durationMinutes)
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
            Text("训练历史")
                .font(.appSubtitle)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.md)

            if trainingRecords.isEmpty {
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.system(size: 42))
                        .foregroundColor(.neonBlue)

                    Text("还没有训练记录")
                        .font(.appBody)
                        .foregroundColor(.textPrimary)

                    Text("完成一次训练后，这里会显示你的历史记录和趋势。")
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
    
    // MARK: - 格式化时长
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return "\(hours) 小时 \(minutes) 分"
        } else {
            return "\(minutes) 分钟"
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
                
                Text(record.programName)
                    .font(.appBody)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
            }
            
            HStack {
                Text("\(record.completedRounds) 轮")
                    .font(.appSmall)
                    .foregroundColor(.neonBlue)
                
                Text("·")
                    .foregroundColor(.textDisabled)
                
                Text("时长：\(formatDuration(record.totalDuration))")
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        if minutes > 0 {
            return String(format: "%d 分钟", minutes)
        }
        return String(format: "%d 秒", seconds)
    }
}

#Preview {
    StatsView()
}

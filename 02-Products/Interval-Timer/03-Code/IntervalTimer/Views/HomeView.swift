// HomeView.swift
// 首页 - 快速开始训练

import SwiftData
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appSession: AppSessionViewModel
    @EnvironmentObject private var programStore: ProgramStore
    @EnvironmentObject private var settingsStore: AppSettingsStore
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TrainingRecord.date, order: .reverse) private var records: [TrainingRecord]
    @State private var errorMessage: String?

    private var quickStartProgram: Program {
        if let lastProgramID = settingsStore.lastProgramID,
           let program = programStore.program(withID: lastProgramID) {
            return program
        }

        return appSession.lastSelectedProgram ?? programStore.presetPrograms[0]
    }

    private var todaySummary: TodayTrainingSummary {
        TodayTrainingSummary(records: records, calendar: .current, now: Date())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundDeep
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        quickStartSection
                        presetProgramsSection
                        todayStatsSection
                    }
                    .padding(.vertical, Spacing.md)
                }
            }
            .navigationBarTitle("Interval Timer", displayMode: .large)
            .navigationBarItems(trailing: NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.neonBlue)
            })
            .alert("无法保存设置", isPresented: errorAlertBinding) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "请稍后重试。")
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var quickStartSection: some View {
        VStack(spacing: Spacing.md) {
            Text("快速开始：\(quickStartProgram.name)")
                .font(.appSubtitle)
                .foregroundColor(.textSecondary)
            
            Text("\(quickStartProgram.workDuration)s 训练 / \(quickStartProgram.restDuration)s 休息")
                .font(.appCaption)
                .foregroundColor(.textSecondary)
            
            Button(action: {
                startProgram(quickStartProgram)
            }) {
                Text("🎯 开始训练")
                    .font(.appTitle)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .primaryButtonStyle()
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(Spacing.md)
        .background(Color.backgroundLight)
        .cornerRadius(CornerRadius.medium)
        .padding(.horizontal, Spacing.md)
    }
    
    private var presetProgramsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("预设训练方案")
                .font(.appSubtitle)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.md)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(programStore.presetPrograms.prefix(5)) { program in
                        ProgramCard(program: program) {
                            startProgram(program)
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }
    
    private var todayStatsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("今日训练统计")
                .font(.appSubtitle)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.md)

            HStack(spacing: Spacing.md) {
                StatCard(icon: "🔥", title: "\(todaySummary.sessionCount) 次", subtitle: "训练次数")
                StatCard(icon: "⏱️", title: formatDuration(todaySummary.totalDuration), subtitle: "训练时长")
            }
            
            HStack(spacing: Spacing.md) {
                StatCard(icon: "📅", title: "\(todaySummary.currentStreakDays) 天", subtitle: "连续训练")
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private func startProgram(_ program: Program) {
        appSession.start(program: program)

        do {
            try settingsStore.setLastProgramID(program.id, in: modelContext)
        } catch {
            errorMessage = "无法保存最近使用的训练方案。"
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        if seconds == 0 {
            return "0 分钟"
        }

        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            return "\(hours) 小时 \(minutes) 分"
        }

        return "\(max(minutes, 1)) 分钟"
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )
    }
}

struct ProgramCard: View {
    let program: Program
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(program.name)
                    .font(.appBody)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text("\(program.workDuration)s")
                    .font(.appSmall)
                    .foregroundColor(.neonBlue)
                
                Text("\(program.rounds) 轮")
                    .font(.appSmall)
                    .foregroundColor(.textSecondary)
            }
            .padding(Spacing.md)
            .frame(width: 120, height: 100)
            .background(Color.backgroundLight)
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(Color.neonBlue.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.appTitle)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.appBody)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text(subtitle)
                    .font(.appSmall)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.backgroundLight)
        .cornerRadius(CornerRadius.medium)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppSessionViewModel())
        .environmentObject(AppSettingsStore())
        .environmentObject(ProgramStore())
}

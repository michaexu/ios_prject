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

    init() {}

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
            .navigationBarTitle(AppLocalization.text("home.title"), displayMode: .large)
            .navigationBarItems(trailing: NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.neonBlue)
            })
            .alert(AppLocalization.text("home.save_settings_failed.title"), isPresented: errorAlertBinding) {
                Button(AppLocalization.text("common.ok"), role: .cancel) {}
            } message: {
                Text(errorMessage ?? AppLocalization.text("common.try_again_later"))
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var quickStartSection: some View {
        VStack(spacing: Spacing.md) {
            Text(AppLocalization.format("home.quick_start", quickStartProgram.displayName))
                .font(.appSubtitle)
                .foregroundColor(.textSecondary)
            
            Text(AppTextFormatters.workRestSummary(work: quickStartProgram.workDuration, rest: quickStartProgram.restDuration))
                .font(.appCaption)
                .foregroundColor(.textSecondary)
            
            Button(action: {
                startProgram(quickStartProgram)
            }) {
                Text(AppLocalization.text("home.start_training"))
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
            Text(AppLocalization.text("home.preset_programs"))
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
            Text(AppLocalization.text("home.today_stats"))
                .font(.appSubtitle)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.md)

            HStack(spacing: Spacing.md) {
                StatCard(
                    icon: "🔥",
                    title: AppTextFormatters.sessionCount(todaySummary.sessionCount),
                    subtitle: AppLocalization.text("stats.label.sessions")
                )
                StatCard(
                    icon: "⏱️",
                    title: AppTextFormatters.overviewDuration(todaySummary.totalDuration),
                    subtitle: AppLocalization.text("stats.label.duration")
                )
            }
            
            HStack(spacing: Spacing.md) {
                StatCard(
                    icon: "📅",
                    title: AppTextFormatters.streakDays(todaySummary.currentStreakDays),
                    subtitle: AppLocalization.text("stats.label.streak")
                )
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private func startProgram(_ program: Program) {
        appSession.start(program: program)

        do {
            try settingsStore.setLastProgramID(program.id, in: modelContext)
        } catch {
            errorMessage = AppLocalization.text("home.save_settings_failed.last_program")
        }
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
                Text(program.displayName)
                    .font(.appBody)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text(AppTextFormatters.workRestSummary(work: program.workDuration, rest: program.restDuration))
                    .font(.appSmall)
                    .foregroundColor(.neonBlue)
                
                Text(AppTextFormatters.rounds(program.rounds))
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

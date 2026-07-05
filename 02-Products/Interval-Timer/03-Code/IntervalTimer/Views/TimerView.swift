// TimerView.swift
// 计时器页面 - 核心功能

import Combine
import SwiftUI

struct TimerScreenPresentation: Equatable {
    let title: String
    let primarySymbol: String
    let accentColor: Color

    static func content(for sessionState: TimerSessionState) -> TimerScreenPresentation {
        switch sessionState {
        case .ready:
            return TimerScreenPresentation(title: AppLocalization.text("timer.ready"), primarySymbol: "play.circle.fill", accentColor: .neonBlue)
        case .running(.work):
            return TimerScreenPresentation(title: AppLocalization.text("timer.running_work"), primarySymbol: "pause.circle.fill", accentColor: .neonBlue)
        case .running(.rest):
            return TimerScreenPresentation(title: AppLocalization.text("timer.running_rest"), primarySymbol: "pause.circle.fill", accentColor: .neonGreen)
        case .paused(.rest):
            return TimerScreenPresentation(title: AppLocalization.text("timer.paused"), primarySymbol: "play.circle.fill", accentColor: .neonGreen)
        case .paused(.work):
            return TimerScreenPresentation(title: AppLocalization.text("timer.paused"), primarySymbol: "play.circle.fill", accentColor: .neonBlue)
        case .completed:
            return TimerScreenPresentation(title: AppLocalization.text("timer.completed"), primarySymbol: "arrow.clockwise.circle.fill", accentColor: .neonGreen)
        }
    }

    static func content(for state: TimerState) -> TimerScreenPresentation {
        switch state {
        case .idle:
            return TimerScreenPresentation(title: AppLocalization.text("timer.ready"), primarySymbol: "play.circle.fill", accentColor: .neonBlue)
        case .work:
            return TimerScreenPresentation(title: AppLocalization.text("timer.running_work"), primarySymbol: "pause.circle.fill", accentColor: .neonBlue)
        case .rest:
            return TimerScreenPresentation(title: AppLocalization.text("timer.running_rest"), primarySymbol: "pause.circle.fill", accentColor: .neonGreen)
        case .paused:
            return TimerScreenPresentation(title: AppLocalization.text("timer.paused"), primarySymbol: "play.circle.fill", accentColor: .neonBlue)
        case .completed:
            return TimerScreenPresentation(title: AppLocalization.text("timer.completed"), primarySymbol: "arrow.clockwise.circle.fill", accentColor: .neonGreen)
        }
    }
}

struct TimerView: View {
    @EnvironmentObject private var appSession: AppSessionViewModel
    @EnvironmentObject private var settingsStore: AppSettingsStore
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            Color.backgroundDeep
                .edgesIgnoringSafeArea(.all)

            if let program = appSession.activeProgram {
                ActiveTimerContent(
                    program: program,
                    timerManager: appSession.timerManager,
                    onBack: { appSession.selectedTab = .home },
                    onStop: { appSession.endSession() }
                )
            } else {
                EmptyTimerState()
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .onAppear {
            appSession.timerManager.attachModelContext(modelContext)
            appSession.timerManager.applySettings(settingsStore.timerReminderSettings)
        }
        .onReceive(settingsPublisher) { settings in
            appSession.timerManager.applySettings(settings)
        }
    }

    private var settingsPublisher: AnyPublisher<TimerReminderSettings, Never> {
        settingsStore.$soundEnabled
            .combineLatest(
                settingsStore.$vibrationEnabled,
                settingsStore.$screenAlwaysOn,
                settingsStore.$selectedSound
            )
            .map { soundEnabled, vibrationEnabled, screenAlwaysOn, selectedSound in
                TimerReminderSettings(
                    soundEnabled: soundEnabled,
                    vibrationEnabled: vibrationEnabled,
                    screenAlwaysOn: screenAlwaysOn,
                    selectedSound: selectedSound
                )
            }
            .eraseToAnyPublisher()
    }
}

private struct ActiveTimerContent: View {
    let program: Program
    @ObservedObject var timerManager: TimerManager
    let onBack: () -> Void
    let onStop: () -> Void

    private var presentation: TimerScreenPresentation {
        TimerScreenPresentation.content(for: timerManager.sessionState)
    }

    var body: some View {
        VStack(spacing: Spacing.xl) {
            topBar
            Spacer()
            timerDisplay
            Spacer()
            controlButtons
            roundIndicator
        }
        .padding(.vertical, Spacing.md)
    }

    private var topBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.textPrimary)
            }

            Spacer()

            Text(program.displayName)
                .font(.appBody)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)

            Spacer()

            Button(action: {}) {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundColor(.textPrimary)
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private var timerDisplay: some View {
        ZStack {
            Circle()
                .stroke(Color.backgroundLight, lineWidth: 8)
                .frame(width: 280, height: 280)

            Circle()
                .trim(from: 0, to: CGFloat(timerManager.progress))
                .stroke(
                    timerManager.state == .work ? LinearGradient.primaryGradient : LinearGradient.purpleBlueGradient,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: timerManager.progress)

            VStack(spacing: Spacing.sm) {
                Text(presentation.title)
                    .font(.appSubtitle)
                    .foregroundColor(presentation.accentColor)

                Text(formatTime(timerManager.currentTime))
                    .font(.custom("System", size: 72))
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)

                Text(AppTextFormatters.roundProgress(current: timerManager.currentRound, total: timerManager.totalRounds))
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
        }
    }

    private var controlButtons: some View {
        VStack(spacing: Spacing.md) {
            Button(action: {
                if timerManager.state == .work || timerManager.state == .rest {
                    timerManager.pause()
                } else if timerManager.state == .completed {
                    timerManager.reset()
                } else {
                    timerManager.start()
                }
            }) {
                Image(systemName: presentation.primarySymbol)
                    .font(.system(size: 80))
                    .foregroundColor(.neonBlue)
            }

            Button(action: onStop) {
                Text(AppLocalization.text("timer.stop"))
                    .font(.appBody)
                    .foregroundColor(.alertRed)
            }
        }
    }

    private var roundIndicator: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(1...timerManager.totalRounds, id: \.self) { round in
                Circle()
                    .fill(round <= timerManager.currentRound ? Color.neonBlue : Color.textDisabled)
                    .frame(width: 12, height: 12)
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

private struct EmptyTimerState: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "timer")
                .font(.system(size: 56))
                .foregroundColor(.neonBlue)

            Text(AppLocalization.text("timer.empty_title"))
                .font(.appTitle)
                .foregroundColor(.textPrimary)

            Text(AppLocalization.text("timer.empty_message"))
                .font(.appBody)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
        }
    }
}

#Preview {
    TimerView()
        .environmentObject(AppSessionViewModel())
}

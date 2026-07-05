// TimerManager.swift
// 计时器管理器 - 核心业务逻辑

import AudioToolbox
import Combine
import Foundation
import SwiftData
import UIKit

enum TimerState: Equatable {
    case idle       // 空闲
    case work       // 训练中
    case rest       // 休息中
    case paused     // 暂停
    case completed  // 完成
}

enum TimerPhase: Equatable {
    case work
    case rest
}

enum TimerSessionState: Equatable {
    case ready
    case running(TimerPhase)
    case paused(TimerPhase)
    case completed
}

struct TimerReminderSettings: Equatable {
    let soundEnabled: Bool
    let vibrationEnabled: Bool
    let screenAlwaysOn: Bool
    let selectedSound: String
}

struct TimerSessionSnapshot: Equatable {
    let hasTrainingStartTime: Bool
    let completedRounds: Int
    let totalWorkDuration: Int
}

@MainActor
final class TimerManager: ObservableObject {
    @Published private(set) var program: Program?
    @Published private(set) var phase: TimerPhase = .work
    @Published var state: TimerState = .idle
    @Published var sessionState: TimerSessionState = .ready
    @Published var currentTime: Int = 0  // 当前剩余时间（秒）
    @Published var currentRound: Int = 1  // 当前轮次
    @Published var totalRounds: Int = 1   // 总轮次
    @Published var progress: Double = 0.0  // 进度 (0.0 - 1.0)

    private var workDuration: Int = 0
    private var restDuration: Int = 0
    private var rounds: Int = 0
    private var phaseDuration: Int = 0
    private var phaseDeadline: Date?
    private var tickerTask: Task<Void, Never>?
    private var modelContext: ModelContext?
    private var hasSavedTrainingRecord = false
    private let nowProvider: () -> Date
    private let idleTimerHandler: (Bool) -> Void
    
    // 设置
    @Published var soundEnabled: Bool = true
    @Published var vibrationEnabled: Bool = true
    @Published var screenAlwaysOn: Bool = true
    @Published var selectedSound: String = AppSettings.defaultSound
    
    // 训练记录
    private var trainingStartTime: Date?
    private var completedRounds: Int = 0
    private var totalWorkDuration: Int = 0

    init(
        nowProvider: @escaping () -> Date = Date.init,
        idleTimerHandler: ((Bool) -> Void)? = nil
    ) {
        self.nowProvider = nowProvider
        self.idleTimerHandler = idleTimerHandler ?? { UIApplication.shared.isIdleTimerDisabled = $0 }
    }

    var currentProgram: Program? {
        program
    }

    var hasScheduledTimer: Bool {
        tickerTask != nil
    }

    var sessionSnapshot: TimerSessionSnapshot {
        TimerSessionSnapshot(
            hasTrainingStartTime: trainingStartTime != nil,
            completedRounds: completedRounds,
            totalWorkDuration: totalWorkDuration
        )
    }

    func attachModelContext(_ context: ModelContext) {
        modelContext = context
    }

    func applySettings(_ settings: TimerReminderSettings) {
        soundEnabled = settings.soundEnabled
        vibrationEnabled = settings.vibrationEnabled
        screenAlwaysOn = settings.screenAlwaysOn
        selectedSound = settings.selectedSound
        updateIdleTimerState()
    }
    
    func setup(program: Program) {
        stopTimer()
        self.program = program
        self.workDuration = program.workDuration
        self.restDuration = program.restDuration
        self.rounds = program.rounds
        self.totalRounds = program.rounds
        self.currentTime = program.workDuration
        self.currentRound = 1
        self.progress = 0.0
        self.phase = .work
        self.phaseDuration = program.workDuration
        self.phaseDeadline = nil
        self.state = .idle
        self.sessionState = .ready
        self.trainingStartTime = nil
        self.completedRounds = 0
        self.totalWorkDuration = 0
        self.hasSavedTrainingRecord = false
        updateIdleTimerState()
    }
    
    func start() {
        guard program != nil else { return }
        guard case .completed = sessionState else {
            if trainingStartTime == nil {
                trainingStartTime = nowProvider()
            }
            phaseDuration = currentPhaseDuration
            if currentTime <= 0 {
                currentTime = phaseDuration
            }
            phaseDeadline = nowProvider().addingTimeInterval(TimeInterval(currentTime))
            setSessionState(.running(phase))
            startTimer()
            processTick()
            return
        }
    }
    
    func pause() {
        guard case .running = sessionState else { return }
        processTick()
        stopTimer()
        phaseDeadline = nil
        setSessionState(.paused(phase))
    }
    
    func reset() {
        stopTimer()
        currentRound = 1
        currentTime = workDuration
        progress = 0.0
        phase = .work
        phaseDuration = workDuration
        phaseDeadline = nil
        trainingStartTime = nil
        completedRounds = 0
        totalWorkDuration = 0
        hasSavedTrainingRecord = false
        setSessionState(.ready)
    }
    
    func stop() {
        processTick()
        stopTimer()
        saveTrainingRecord(at: nowProvider())
        currentTime = max(currentTime, 0)
        setSessionState(.completed)
    }

    func clear() {
        stopTimer()
        program = nil
        setSessionState(.ready)
        currentTime = 0
        currentRound = 1
        totalRounds = 0
        progress = 0.0
        workDuration = 0
        restDuration = 0
        rounds = 0
        phase = .work
        phaseDuration = 0
        phaseDeadline = nil
        trainingStartTime = nil
        completedRounds = 0
        totalWorkDuration = 0
        hasSavedTrainingRecord = false
    }

    func processTick() {
        refreshForCurrentTime()
    }

    private func startTimer() {
        stopTimer()
        tickerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 200_000_000)
                await MainActor.run {
                    self?.processTick()
                }
            }
        }
    }
    
    private func stopTimer() {
        tickerTask?.cancel()
        tickerTask = nil
        updateIdleTimerState()
    }
    
    private func refreshForCurrentTime() {
        guard case .running = sessionState,
              let phaseDeadline else { return }

        let now = nowProvider()
        let remainingTime = max(0, Int(ceil(phaseDeadline.timeIntervalSince(now))))
        currentTime = remainingTime

        if phaseDuration > 0 {
            let remainingProgress = Double(remainingTime) / Double(phaseDuration)
            progress = min(max(1.0 - remainingProgress, 0.0), 1.0)
        } else {
            progress = 1.0
        }

        if remainingTime <= 0 {
            phaseCompleted(at: now)
        }
    }

    private func phaseCompleted(at now: Date) {
        // 播放提示音和震动
        if soundEnabled {
            playSound()
        }
        if vibrationEnabled {
            playVibration()
        }
        
        if phase == .work {
            // 训练阶段完成
            totalWorkDuration += workDuration
            completedRounds += 1
            
            if currentRound >= rounds {
                // 所有轮次完成
                stopTimer()
                currentTime = 0
                progress = 1.0
                setSessionState(.completed)
                saveTrainingRecord(at: now)
                playCompletionSound()
            } else {
                // 进入休息阶段
                beginPhase(.rest, duration: restDuration, at: now)
            }
        } else {
            // 休息阶段完成
            currentRound += 1
            beginPhase(.work, duration: workDuration, at: now)
        }
    }
    
    private func playSound() {
        AudioServicesPlaySystemSound(selectedSoundID)
    }
    
    private func playVibration() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func playCompletionSound() {
        AudioServicesPlaySystemSound(1016) // 完成音效
    }
    
    private func saveTrainingRecord(at endTime: Date) {
        guard let program = program,
              let startTime = trainingStartTime,
              !hasSavedTrainingRecord else { return }
        
        let totalDuration = Int(endTime.timeIntervalSince(startTime))
        
        let record = TrainingRecord(
            programId: program.id,
            programName: program.name,
            date: endTime,
            totalDuration: totalDuration,
            completedRounds: completedRounds,
            totalWorkDuration: totalWorkDuration
        )

        if let modelContext {
            modelContext.insert(record)
            try? modelContext.save()
            hasSavedTrainingRecord = true
        }
    }

    private var currentPhaseDuration: Int {
        phase == .work ? workDuration : restDuration
    }

    private func beginPhase(_ nextPhase: TimerPhase, duration: Int, at now: Date) {
        phase = nextPhase
        phaseDuration = duration
        currentTime = duration
        progress = 0.0
        phaseDeadline = now.addingTimeInterval(TimeInterval(duration))
        setSessionState(.running(nextPhase))
        processTick()
    }

    private func setSessionState(_ newState: TimerSessionState) {
        sessionState = newState
        state = newState.timerState
        updateIdleTimerState()
    }

    private func updateIdleTimerState() {
        idleTimerHandler(screenAlwaysOn && sessionState.keepsScreenAwake)
    }

    private var selectedSoundID: SystemSoundID {
        switch selectedSound {
        case "Bell":
            return 1013
        case "嘟嘟嘟":
            return 1012
        case "叮叮叮":
            return 1005
        default:
            return 1005
        }
    }
    
    deinit {
        Task { @MainActor [tickerTask, idleTimerHandler] in
            tickerTask?.cancel()
            idleTimerHandler(false)
        }
    }
}

private extension TimerSessionState {
    var timerState: TimerState {
        switch self {
        case .ready:
            return .idle
        case .running(.work):
            return .work
        case .running(.rest):
            return .rest
        case .paused:
            return .paused
        case .completed:
            return .completed
        }
    }

    var keepsScreenAwake: Bool {
        switch self {
        case .running, .paused:
            return true
        case .ready, .completed:
            return false
        }
    }
}

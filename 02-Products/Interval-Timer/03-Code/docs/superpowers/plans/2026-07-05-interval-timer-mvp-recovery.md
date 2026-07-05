# Interval Timer MVP Recovery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore the app from its current blank/non-functional state and implement the V1 design-doc features for timer flow, program management, settings, and training statistics.

**Architecture:** Keep the existing SwiftUI app structure, but introduce a single shared app store layer that owns SwiftData-backed programs, training records, and user settings. Route every screen through one shared navigation/state model so the timer can start consistently from Home, Programs, and the Timer tab without duplicated `TimerManager` instances.

**Tech Stack:** SwiftUI, SwiftData, AVFoundation, UIKit, Charts

---

### Task 1: Rebuild the app shell and shared state

**Files:**
- Modify: `IntervalTimer/IntervalTimerApp.swift`
- Modify: `IntervalTimer/Views/HomeView.swift`
- Modify: `IntervalTimer/Views/ProgramsView.swift`
- Modify: `IntervalTimer/Views/TimerView.swift`
- Create: `IntervalTimer/ViewModels/AppSettingsStore.swift`
- Create: `IntervalTimer/ViewModels/ProgramStore.swift`

- [ ] **Step 1: Write the failing shell expectations**

```swift
// Expected behavior after this task:
// 1. App launches into a populated TabView instead of a disconnected shell.
// 2. Home "开始训练" opens TimerView with the selected program.
// 3. Programs list "play" action also opens the shared timer flow.
// 4. Timer tab no longer shows an empty/unconfigured timer by default.
```

- [ ] **Step 2: Add shared app stores and inject them at the app root**

```swift
@main
struct IntervalTimerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Program.self, TrainingRecord.self, AppSettings.self])
        return try! ModelContainer(for: schema)
    }()

    @StateObject private var timerManager = TimerManager()
    @StateObject private var settingsStore = AppSettingsStore()
    @StateObject private var programStore = ProgramStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(timerManager)
                .environmentObject(settingsStore)
                .environmentObject(programStore)
        }
        .modelContainer(sharedModelContainer)
    }
}
```

- [ ] **Step 3: Replace local timer state in Home with shared navigation logic**

```swift
@EnvironmentObject private var timerManager: TimerManager
@EnvironmentObject private var programStore: ProgramStore
@State private var activeProgram: Program?

NavigationStack {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            quickStartSection
            presetProgramsSection
            todayStatsSection
        }
        .padding(.vertical, Spacing.md)
    }
    .navigationDestination(item: $activeProgram) { program in
        TimerView(program: program)
    }
}

private func start(_ program: Program) {
    timerManager.setup(program: program)
    activeProgram = program
}
```

- [ ] **Step 4: Make Programs launch or edit through the same shared state**

```swift
ProgramRow(program: program) {
    timerManager.setup(program: program)
    activeProgram = program
}

.sheet(item: $editingProgram) { program in
    ProgramEditorView(program: program)
}
```

- [ ] **Step 5: Make TimerView resilient when no session is active**

```swift
if let program = timerManager.program {
    ActiveTimerContent(program: program, timerManager: timerManager)
} else {
    EmptyTimerState(
        title: "还没有开始训练",
        subtitle: "从首页或方案页选择一个训练方案开始。"
    )
}
```

- [ ] **Step 6: Run a build check for the app shell**

Run: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project IntervalTimer.xcodeproj -scheme "Interval Timer" -destination 'generic/platform=iOS Simulator' build`
Expected: build succeeds, or any remaining compiler errors point only to unimplemented store/model work from later tasks

- [ ] **Step 7: Commit**

```bash
git add IntervalTimer/IntervalTimerApp.swift IntervalTimer/Views/HomeView.swift IntervalTimer/Views/ProgramsView.swift IntervalTimer/Views/TimerView.swift IntervalTimer/ViewModels/AppSettingsStore.swift IntervalTimer/ViewModels/ProgramStore.swift
git commit -m "fix: restore app shell and shared timer navigation"
```

### Task 2: Persist programs, settings, and real records with SwiftData

**Files:**
- Modify: `IntervalTimer/Models/Program.swift`
- Create: `IntervalTimer/Models/AppSettings.swift`
- Modify: `IntervalTimer/Views/ProgramsView.swift`
- Modify: `IntervalTimer/Views/SettingsView.swift`
- Modify: `IntervalTimer/ViewModels/ProgramStore.swift`
- Modify: `IntervalTimer/ViewModels/AppSettingsStore.swift`

- [ ] **Step 1: Define the missing persisted settings model**

```swift
@Model
final class AppSettings {
    var soundEnabled: Bool
    var vibrationEnabled: Bool
    var screenAlwaysOn: Bool
    var selectedSound: String
    var lastProgramID: UUID?

    init(
        soundEnabled: Bool = true,
        vibrationEnabled: Bool = true,
        screenAlwaysOn: Bool = true,
        selectedSound: String = "嘀嘀嘀",
        lastProgramID: UUID? = nil
    ) {
        self.soundEnabled = soundEnabled
        self.vibrationEnabled = vibrationEnabled
        self.screenAlwaysOn = screenAlwaysOn
        self.selectedSound = selectedSound
        self.lastProgramID = lastProgramID
    }
}
```

- [ ] **Step 2: Split preset data from user-managed programs**

```swift
extension Program {
    static var presets: [ProgramSeed] = [
        .init(name: "Tabata", workDuration: 20, restDuration: 10, rounds: 8),
        .init(name: "7分钟训练", workDuration: 30, restDuration: 10, rounds: 12),
        .init(name: "HIIT 初级", workDuration: 45, restDuration: 15, rounds: 10),
        .init(name: "HIIT 高级", workDuration: 60, restDuration: 20, rounds: 15),
        .init(name: "自定义", workDuration: 30, restDuration: 30, rounds: 5),
    ]
}
```

- [ ] **Step 3: Implement store methods for bootstrap, save, update, and delete**

```swift
final class ProgramStore: ObservableObject {
    @Published private(set) var customPrograms: [Program] = []

    func load(from context: ModelContext) throws {
        let descriptor = FetchDescriptor<Program>(
            predicate: #Predicate { !$0.isPreset },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        customPrograms = try context.fetch(descriptor)
    }

    func saveProgram(_ draft: ProgramDraft, editing: Program?, context: ModelContext) throws {
        let program = editing ?? Program(
            name: draft.name,
            workDuration: draft.workDuration,
            restDuration: draft.restDuration,
            rounds: draft.rounds
        )
        program.name = draft.name
        program.workDuration = draft.workDuration
        program.restDuration = draft.restDuration
        program.rounds = draft.rounds

        if editing == nil {
            context.insert(program)
        }

        try context.save()
        try load(from: context)
    }

    func deletePrograms(at offsets: IndexSet, context: ModelContext) throws {
        for index in offsets {
            context.delete(customPrograms[index])
        }
        try context.save()
        try load(from: context)
    }
}
```

- [ ] **Step 4: Wire ProgramsView and editor to real persisted data**

```swift
@Environment(\.modelContext) private var modelContext
@Query(sort: \Program.createdAt, order: .reverse) private var savedPrograms: [Program]

Button("保存") {
    try? programStore.saveProgram(
        ProgramDraft(name: name, workDuration: workDuration, restDuration: restDuration, rounds: rounds),
        editing: editingProgram,
        context: modelContext
    )
    dismiss()
}
```

- [ ] **Step 5: Make settings changes load and save immediately**

```swift
Toggle("声音提醒", isOn: $settingsStore.settings.soundEnabled)
    .onChange(of: settingsStore.settings.soundEnabled) { _, _ in
        settingsStore.saveIfNeeded()
    }
```

- [ ] **Step 6: Run a build check for persistence and settings**

Run: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project IntervalTimer.xcodeproj -scheme "Interval Timer" -destination 'generic/platform=iOS Simulator' build`
Expected: build succeeds with persisted models compiling and no placeholder save logic left in Programs or Settings

- [ ] **Step 7: Commit**

```bash
git add IntervalTimer/Models/Program.swift IntervalTimer/Models/AppSettings.swift IntervalTimer/Views/ProgramsView.swift IntervalTimer/Views/SettingsView.swift IntervalTimer/ViewModels/ProgramStore.swift IntervalTimer/ViewModels/AppSettingsStore.swift
git commit -m "feat: persist programs and settings with swiftdata"
```

### Task 3: Upgrade timer execution, reminders, and record saving

**Files:**
- Modify: `IntervalTimer/ViewModels/TimerManager.swift`
- Modify: `IntervalTimer/Views/TimerView.swift`
- Modify: `IntervalTimer/ViewModels/AppSettingsStore.swift`
- Modify: `IntervalTimer/Models/Program.swift`

- [ ] **Step 1: Replace the current timer with elapsed-time-driven ticking**

```swift
private var timer: DispatchSourceTimer?
private var phaseStartDate: Date?
private var pausedRemaining: TimeInterval = 0

private func startTimer() {
    phaseStartDate = Date()
    let queue = DispatchQueue(label: "interval-timer.tick")
    let timer = DispatchSource.makeTimerSource(queue: queue)
    timer.schedule(deadline: .now(), repeating: .milliseconds(100))
    timer.setEventHandler { [weak self] in
        self?.handleTick(now: Date())
    }
    self.timer = timer
    timer.resume()
}
```

- [ ] **Step 2: Track current program and current phase explicitly**

```swift
enum TimerPhase {
    case idle
    case work(round: Int)
    case rest(round: Int)
    case paused(previous: TimerPhase)
    case completed
}

@Published private(set) var program: Program?
@Published private(set) var phase: TimerPhase = .idle
```

- [ ] **Step 3: Apply settings to sound, haptics, and screen idle behavior**

```swift
func apply(settings: AppSettings) {
    soundEnabled = settings.soundEnabled
    vibrationEnabled = settings.vibrationEnabled
    selectedSound = settings.selectedSound
    screenAlwaysOn = settings.screenAlwaysOn
}

private func updateIdleTimer(isRunning: Bool) {
    DispatchQueue.main.async {
        UIApplication.shared.isIdleTimerDisabled = isRunning && self.screenAlwaysOn
    }
}
```

- [ ] **Step 4: Save completed sessions as real TrainingRecord rows**

```swift
func attachModelContext(_ context: ModelContext) {
    self.modelContext = context
}

private func saveTrainingRecord() {
    guard let program, let modelContext, let trainingStartTime else { return }
    let record = TrainingRecord(
        programId: program.id,
        programName: program.name,
        date: Date(),
        totalDuration: Int(Date().timeIntervalSince(trainingStartTime)),
        completedRounds: completedRounds,
        totalWorkDuration: totalWorkDuration
    )
    modelContext.insert(record)
    try? modelContext.save()
}
```

- [ ] **Step 5: Refresh TimerView UI states for ready, running, paused, and completed**

```swift
switch timerManager.phase {
case .idle:
    Text("准备开始")
case .work:
    Text("训练中")
case .rest:
    Text("休息中")
case .paused:
    Text("已暂停")
case .completed:
    Text("训练完成")
}
```

- [ ] **Step 6: Run a build check for timer execution**

Run: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project IntervalTimer.xcodeproj -scheme "Interval Timer" -destination 'generic/platform=iOS Simulator' build`
Expected: build succeeds and `TimerManager` no longer depends on `Timer.scheduledTimer`

- [ ] **Step 7: Commit**

```bash
git add IntervalTimer/ViewModels/TimerManager.swift IntervalTimer/Views/TimerView.swift IntervalTimer/ViewModels/AppSettingsStore.swift IntervalTimer/Models/Program.swift
git commit -m "feat: implement accurate timer flow and record saving"
```

### Task 4: Replace placeholder stats and finish MVP polish

**Files:**
- Modify: `IntervalTimer/Views/HomeView.swift`
- Modify: `IntervalTimer/Views/StatsView.swift`
- Modify: `IntervalTimer/Views/ProgramsView.swift`
- Modify: `IntervalTimer/ViewModels/ProgramStore.swift`
- Optional Test: `Interval TimerTests/Interval_TimerTests.swift`

- [ ] **Step 1: Compute Home and Stats data from real records**

```swift
@Query(sort: \TrainingRecord.date, order: .reverse) private var records: [TrainingRecord]

private var todaySummary: TodaySummary {
    TodaySummary(records: records, calendar: .current, now: Date())
}

private var weeklySummary: WeeklySummary {
    WeeklySummary(records: records, calendar: .current, now: Date())
}
```

- [ ] **Step 2: Replace fake chart bars and sample history with deterministic data**

```swift
Chart(weeklySummary.dailyDurations) { item in
    BarMark(
        x: .value("星期", item.weekdayLabel),
        y: .value("时长", item.durationMinutes)
    )
    .foregroundStyle(LinearGradient.primaryGradient)
}

ForEach(records.prefix(20)) { record in
    TrainingRecordRow(record: record)
}
```

- [ ] **Step 3: Complete Programs UX for create, edit, and delete**

```swift
ForEach(savedPrograms) { program in
    ProgramRow(program: program) {
        timerManager.setup(program: program)
        activeProgram = program
    }
}
.onDelete { offsets in
    try? programStore.deletePrograms(at: offsets, context: modelContext)
}
```

- [ ] **Step 4: Show the last-used program on Home for quick start**

```swift
private var quickStartProgram: Program {
    programStore.lastUsedProgram(from: savedPrograms) ?? Program.presets[0].makeProgram()
}
```

- [ ] **Step 5: Run the final verification sweep**

Run: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project IntervalTimer.xcodeproj -scheme "Interval Timer" -destination 'generic/platform=iOS Simulator' build`
Expected: build succeeds with Home, Programs, Timer, Stats, and Settings all compiling from the same shared data model

Run: `git status --short`
Expected: only intentional app and docs changes remain

- [ ] **Step 6: Commit**

```bash
git add IntervalTimer/Views/HomeView.swift IntervalTimer/Views/StatsView.swift IntervalTimer/Views/ProgramsView.swift IntervalTimer/ViewModels/ProgramStore.swift "Interval TimerTests/Interval_TimerTests.swift"
git commit -m "feat: complete stats and program management mvp"
```

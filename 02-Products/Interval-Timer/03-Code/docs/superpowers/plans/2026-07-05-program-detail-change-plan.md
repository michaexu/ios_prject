# Program Detail Change Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Finish the program-detail requirement by aligning duration formatting with the requirement log, verifying it with tests, and marking the change log item complete.

**Architecture:** Reuse the existing `ProgramRow` and `ProgramDetailView` implementation, but centralize `MM:SS` formatting inside the `Program` model so the UI and tests share one rule. Keep the change narrowly scoped to the programs feature and requirement-tracking docs.

**Tech Stack:** SwiftUI, SwiftData, XCTest

---

### Task 1: Align program detail formatting with REQ-001

**Files:**
- Modify: `IntervalTimer/Models/Program.swift`
- Modify: `IntervalTimer/Views/ProgramsView.swift`
- Test: `Interval TimerTests/ProgramStoreTests.swift`

- [ ] **Step 1: Add failing assertions for `MM:SS` duration formatting**

```swift
func testProgramFormatsDetailDurationsAsMinutesAndSeconds() {
    let program = Program(name: "Format", workDuration: 65, restDuration: 5, rounds: 3)

    XCTAssertEqual(program.formattedWorkDuration, "01:05")
    XCTAssertEqual(program.formattedRestDuration, "00:05")
    XCTAssertEqual(program.formattedTotalWorkDuration, "03:15")
    XCTAssertEqual(program.formattedTotalRestDuration, "00:10")
}
```

- [ ] **Step 2: Run the tests to confirm the new assertions fail**

Run: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild build-for-testing -project IntervalTimer.xcodeproj -scheme "Interval Timer" -destination "generic/platform=iOS Simulator" -derivedDataPath /private/tmp/interval-timer-derived CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=""`
Expected: build or test target requires the new model helpers

- [ ] **Step 3: Implement reusable formatting helpers on `Program`**

```swift
var formattedWorkDuration: String { Self.mmss(workDuration) }
var formattedRestDuration: String { Self.mmss(restDuration) }
var formattedTotalWorkDuration: String { Self.mmss(workDuration * rounds) }
var formattedTotalRestDuration: String { Self.mmss(restDuration * max(rounds - 1, 0)) }

private static func mmss(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60
    return String(format: "%02d:%02d", minutes, remainingSeconds)
}
```

- [ ] **Step 4: Update `ProgramDetailView` to use the shared helpers**

```swift
detailRow(label: "训练时间", value: program.formattedWorkDuration, color: .neonBlue)
detailRow(label: "休息时间", value: program.formattedRestDuration, color: .neonGreen)
detailRow(label: "总时长", value: program.formattedTotalDuration, color: .neonBlue)
detailRow(label: "总训练时间", value: program.formattedTotalWorkDuration, color: .neonBlue)
detailRow(label: "总休息时间", value: program.formattedTotalRestDuration, color: .neonGreen)
```

- [ ] **Step 5: Re-run the build verification**

Run: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild build-for-testing -project IntervalTimer.xcodeproj -scheme "Interval Timer" -destination "generic/platform=iOS Simulator" -derivedDataPath /private/tmp/interval-timer-derived CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=""`
Expected: `TEST BUILD SUCCEEDED`

### Task 2: Mark the requirement change complete

**Files:**
- Modify: `01-PRD/Requirement-Change-Log.md`

- [ ] **Step 1: Update the requirement status**

```md
- **状态**：已完成
```

- [ ] **Step 2: Add a short completion note under impact or acceptance if helpful**

```md
已在 `03-Code/IntervalTimer/Views/ProgramsView.swift` 中完成方案详情入口与明细视图。
```

- [ ] **Step 3: Verify the working tree state**

Run: `git status --short`
Expected: only intentional `Program.swift`, `ProgramsView.swift`, tests, spec/plan docs, and requirement-log changes appear

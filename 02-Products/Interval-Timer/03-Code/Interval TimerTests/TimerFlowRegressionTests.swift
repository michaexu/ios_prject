import XCTest
@testable import Interval_Timer

final class TimerFlowRegressionTests: XCTestCase {
    @MainActor
    func testStartingNewProgramStopsExistingScheduledTimerAndResetsManager() {
        let session = AppSessionViewModel()
        let firstProgram = Program(name: "First", workDuration: 20, restDuration: 10, rounds: 8)
        let secondProgram = Program(name: "Second", workDuration: 45, restDuration: 15, rounds: 6)

        session.start(program: firstProgram)
        session.timerManager.start()

        XCTAssertTrue(session.timerManager.hasScheduledTimer)

        session.start(program: secondProgram)

        XCTAssertFalse(session.timerManager.hasScheduledTimer)
        XCTAssertEqual(session.timerManager.sessionSnapshot.completedRounds, 0)
        XCTAssertEqual(session.timerManager.sessionSnapshot.totalWorkDuration, 0)
        XCTAssertFalse(session.timerManager.sessionSnapshot.hasTrainingStartTime)
        XCTAssertEqual(session.timerManager.currentTime, 45)
        XCTAssertEqual(session.timerManager.state, .idle)
    }

    func testTimerScreenPresentationHandlesNonWorkStatesExplicitly() {
        XCTAssertEqual(TimerScreenPresentation.content(for: TimerState.idle).title, "准备开始")
        XCTAssertEqual(TimerScreenPresentation.content(for: TimerState.idle).primarySymbol, "play.circle.fill")
        XCTAssertEqual(TimerScreenPresentation.content(for: TimerState.paused).title, "已暂停")
        XCTAssertEqual(TimerScreenPresentation.content(for: TimerState.completed).title, "已完成")
        XCTAssertEqual(TimerScreenPresentation.content(for: TimerState.completed).primarySymbol, "arrow.clockwise.circle.fill")
    }
}

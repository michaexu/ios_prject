import XCTest
@testable import Interval_Timer

final class AppSessionViewModelTests: XCTestCase {
    @MainActor
    func testStartProgramConfiguresSharedTimerAndSelectsTimerTab() {
        let session = AppSessionViewModel()
        let program = Program(name: "Test", workDuration: 40, restDuration: 20, rounds: 6)

        session.start(program: program)

        XCTAssertEqual(session.selectedTab, .timer)
        XCTAssertEqual(session.activeProgram?.id, program.id)
        XCTAssertEqual(session.timerManager.currentTime, 40)
        XCTAssertEqual(session.timerManager.totalRounds, 6)
        XCTAssertEqual(session.timerManager.currentProgram?.id, program.id)
    }

    @MainActor
    func testStartProgramRemembersLastSelectedProgramForQuickStart() {
        let session = AppSessionViewModel()
        let firstProgram = Program(name: "First", workDuration: 20, restDuration: 10, rounds: 8)
        let secondProgram = Program(name: "Second", workDuration: 50, restDuration: 15, rounds: 5)

        session.start(program: firstProgram)
        session.start(program: secondProgram)

        XCTAssertEqual(session.lastSelectedProgram?.id, secondProgram.id)
    }
}

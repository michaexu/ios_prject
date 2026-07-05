import Foundation
import SwiftData
import XCTest
@testable import Interval_Timer

@MainActor
final class TimerManagerTests: XCTestCase {
    func testTickUsesElapsedTimeToUpdateRemainingTimeAndProgress() throws {
        var now = Date(timeIntervalSince1970: 100)
        let manager = TimerManager(nowProvider: { now }, idleTimerHandler: { _ in })
        let program = Program(name: "Tempo", workDuration: 10, restDuration: 5, rounds: 2)

        manager.setup(program: program)
        manager.start()

        now = now.addingTimeInterval(3)
        manager.processTick()

        XCTAssertEqual(manager.sessionState, .running(.work))
        XCTAssertEqual(manager.currentTime, 7)
        XCTAssertEqual(manager.progress, 0.3, accuracy: 0.001)
    }

    func testSessionStateTransitionsAcrossPauseRestAndCompletion() throws {
        var now = Date(timeIntervalSince1970: 200)
        let manager = TimerManager(nowProvider: { now }, idleTimerHandler: { _ in })
        let program = Program(name: "Flow", workDuration: 2, restDuration: 1, rounds: 2)

        manager.setup(program: program)
        XCTAssertEqual(manager.sessionState, .ready)

        manager.start()
        XCTAssertEqual(manager.sessionState, .running(.work))

        manager.pause()
        XCTAssertEqual(manager.sessionState, .paused(.work))

        manager.start()
        now = now.addingTimeInterval(2)
        manager.processTick()
        XCTAssertEqual(manager.sessionState, .running(.rest))
        XCTAssertEqual(manager.currentRound, 1)

        now = now.addingTimeInterval(1)
        manager.processTick()
        XCTAssertEqual(manager.sessionState, .running(.work))
        XCTAssertEqual(manager.currentRound, 2)

        now = now.addingTimeInterval(2)
        manager.processTick()
        XCTAssertEqual(manager.sessionState, .completed)
        XCTAssertEqual(manager.state, .completed)
    }

    func testStopPersistsTrainingRecordIntoModelContext() throws {
        var now = Date(timeIntervalSince1970: 300)
        let container = try makeContainer()
        let context = ModelContext(container)
        let manager = TimerManager(nowProvider: { now }, idleTimerHandler: { _ in })
        let program = Program(name: "Persist", workDuration: 10, restDuration: 5, rounds: 1)

        manager.attachModelContext(context)
        manager.setup(program: program)
        manager.start()

        now = now.addingTimeInterval(4)
        manager.stop()

        let records = try context.fetch(FetchDescriptor<TrainingRecord>())
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0].programId, program.id)
        XCTAssertEqual(records[0].programName, "Persist")
        XCTAssertEqual(records[0].totalDuration, 4)
        XCTAssertEqual(records[0].completedRounds, 0)
        XCTAssertEqual(records[0].totalWorkDuration, 0)
    }

    func testApplyingSettingsUpdatesReminderPreferencesAndIdleBehavior() throws {
        var idleStates: [Bool] = []
        let manager = TimerManager(
            nowProvider: { Date(timeIntervalSince1970: 400) },
            idleTimerHandler: { idleStates.append($0) }
        )
        let program = Program(name: "Settings", workDuration: 5, restDuration: 5, rounds: 1)

        manager.setup(program: program)
        manager.applySettings(.init(soundEnabled: false, vibrationEnabled: false, screenAlwaysOn: true, selectedSound: "Bell"))

        XCTAssertFalse(manager.soundEnabled)
        XCTAssertFalse(manager.vibrationEnabled)
        XCTAssertEqual(manager.selectedSound, AppSound.beep.identifier)
        XCTAssertFalse(idleStates.last ?? false)

        manager.start()
        XCTAssertTrue(idleStates.last ?? false)

        manager.reset()
        XCTAssertFalse(idleStates.last ?? true)
    }

    func testSetupAndPhaseTransitionsExposeCurrentProgramAndPhase() throws {
        var now = Date(timeIntervalSince1970: 500)
        let manager = TimerManager(nowProvider: { now }, idleTimerHandler: { _ in })
        let program = Program(name: "Expose", workDuration: 2, restDuration: 1, rounds: 2)

        manager.setup(program: program)
        XCTAssertEqual(manager.program?.id, program.id)
        XCTAssertEqual(manager.phase, .work)

        manager.start()
        now = now.addingTimeInterval(2)
        manager.processTick()

        XCTAssertEqual(manager.phase, .rest)
    }

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([Program.self, TrainingRecord.self, AppSettings.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: configuration)
    }
}

import SwiftData
import XCTest
@testable import Interval_Timer

@MainActor
final class ProgramStoreTests: XCTestCase {
    func testLoadCustomProgramsIncludesOnlyPersistedNonPresetPrograms() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let customProgram = Program(name: "Custom", workDuration: 40, restDuration: 20, rounds: 6)
        let presetProgram = Program(name: "Preset", workDuration: 20, restDuration: 10, rounds: 8, isPreset: true)
        let store = ProgramStore()

        context.insert(customProgram)
        context.insert(presetProgram)
        try context.save()

        try store.loadCustomPrograms(from: context)

        XCTAssertEqual(store.customPrograms.count, 1)
        XCTAssertEqual(store.customPrograms.first?.id, customProgram.id)
        XCTAssertFalse(store.customPrograms.contains(where: \.isPreset))
    }

    func testSavePersistsNewCustomProgram() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = ProgramStore()
        let program = Program(name: "Intervals", workDuration: 50, restDuration: 15, rounds: 7)

        try store.save(program, in: context)

        let persistedPrograms = try context.fetch(FetchDescriptor<Program>())
        XCTAssertEqual(store.customPrograms.count, 1)
        XCTAssertEqual(persistedPrograms.count, 1)
        XCTAssertEqual(persistedPrograms.first?.id, program.id)
        XCTAssertFalse(persistedPrograms.first?.isPreset ?? true)
    }

    func testSaveUpdatesExistingPersistedCustomProgramInsteadOfDuplicatingIt() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = ProgramStore()
        let originalProgram = Program(name: "Intervals", workDuration: 45, restDuration: 15, rounds: 6)

        try store.save(originalProgram, in: context)

        let updatedProgram = Program(
            id: originalProgram.id,
            name: "Updated Intervals",
            workDuration: 60,
            restDuration: 20,
            rounds: 8,
            createdAt: originalProgram.createdAt
        )

        try store.save(updatedProgram, in: context)

        let persistedPrograms = try context.fetch(FetchDescriptor<Program>())
        XCTAssertEqual(persistedPrograms.count, 1)
        XCTAssertEqual(persistedPrograms.first?.name, "Updated Intervals")
        XCTAssertEqual(persistedPrograms.first?.workDuration, 60)
        XCTAssertEqual(store.customPrograms.first?.name, "Updated Intervals")
    }

    func testDeleteRemovesPersistedCustomProgram() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = ProgramStore()
        let program = Program(name: "Delete Me", workDuration: 30, restDuration: 10, rounds: 5)

        try store.save(program, in: context)
        try store.delete(program, from: context)

        let persistedPrograms = try context.fetch(FetchDescriptor<Program>())
        XCTAssertTrue(persistedPrograms.isEmpty)
        XCTAssertTrue(store.customPrograms.isEmpty)
    }

    func testProgramFormatsDetailDurationsAsMinutesAndSeconds() {
        let program = Program(name: "Format", workDuration: 65, restDuration: 5, rounds: 3)

        XCTAssertEqual(program.formattedWorkDuration, "01:05")
        XCTAssertEqual(program.formattedRestDuration, "00:05")
        XCTAssertEqual(program.formattedTotalDuration, "03:25")
        XCTAssertEqual(program.formattedTotalWorkDuration, "03:15")
        XCTAssertEqual(program.formattedTotalRestDuration, "00:10")
    }

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([Program.self, TrainingRecord.self, AppSettings.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: configuration)
    }
}

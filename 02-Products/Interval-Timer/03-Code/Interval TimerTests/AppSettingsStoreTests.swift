import SwiftData
import XCTest
@testable import Interval_Timer

@MainActor
final class AppSettingsStoreTests: XCTestCase {
    func testLoadCreatesDefaultPersistedSettingsWhenMissing() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = AppSettingsStore()

        try store.load(from: context)

        XCTAssertTrue(store.soundEnabled)
        XCTAssertTrue(store.vibrationEnabled)
        XCTAssertTrue(store.screenAlwaysOn)
        XCTAssertNil(store.lastProgramID)

        let persistedSettings = try context.fetch(FetchDescriptor<AppSettings>())
        XCTAssertEqual(persistedSettings.count, 1)
        XCTAssertTrue(persistedSettings[0].soundEnabled)
        XCTAssertTrue(persistedSettings[0].vibrationEnabled)
        XCTAssertTrue(persistedSettings[0].screenAlwaysOn)
        XCTAssertEqual(persistedSettings[0].selectedSound, AppSettings.defaultSound)
        XCTAssertNil(persistedSettings[0].lastProgramID)
    }

    func testLoadUsesPersistedSettingsValues() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = AppSettingsStore()
        let programID = UUID()
        let settings = AppSettings(
            soundEnabled: false,
            vibrationEnabled: false,
            screenAlwaysOn: false,
            selectedSound: "叮叮叮",
            lastProgramID: programID
        )

        context.insert(settings)
        try context.save()

        try store.load(from: context)

        XCTAssertFalse(store.soundEnabled)
        XCTAssertFalse(store.vibrationEnabled)
        XCTAssertFalse(store.screenAlwaysOn)
        XCTAssertEqual(store.selectedSound, AppSound.chime.identifier)
        XCTAssertEqual(store.lastProgramID, programID)
    }

    func testUpdateMethodsPersistChangesImmediately() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = AppSettingsStore()
        let programID = UUID()

        try store.load(from: context)
        try store.setSoundEnabled(false, in: context)
        try store.setVibrationEnabled(false, in: context)
        try store.setScreenAlwaysOn(false, in: context)
        try store.setSelectedSound("嘟嘟嘟", in: context)
        try store.setLastProgramID(programID, in: context)

        let persistedSettings = try context.fetch(FetchDescriptor<AppSettings>())
        XCTAssertEqual(persistedSettings.count, 1)
        XCTAssertFalse(store.soundEnabled)
        XCTAssertFalse(store.vibrationEnabled)
        XCTAssertFalse(store.screenAlwaysOn)
        XCTAssertEqual(store.selectedSound, AppSound.tone.identifier)
        XCTAssertEqual(store.lastProgramID, programID)
        XCTAssertFalse(persistedSettings[0].soundEnabled)
        XCTAssertFalse(persistedSettings[0].vibrationEnabled)
        XCTAssertFalse(persistedSettings[0].screenAlwaysOn)
        XCTAssertEqual(persistedSettings[0].selectedSound, AppSound.tone.identifier)
        XCTAssertEqual(persistedSettings[0].lastProgramID, programID)
    }

    func testLoadCollapsesDuplicateSettingsRowsDeterministically() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = AppSettingsStore()
        let olderID = UUID()
        let olderSettings = AppSettings(
            soundEnabled: false,
            vibrationEnabled: false,
            screenAlwaysOn: false,
            selectedSound: "叮叮叮",
            lastProgramID: olderID,
            createdAt: Date(timeIntervalSince1970: 10)
        )
        let newerID = UUID()
        let newerSettings = AppSettings(
            soundEnabled: true,
            vibrationEnabled: true,
            screenAlwaysOn: true,
            selectedSound: "嘟嘟嘟",
            lastProgramID: newerID,
            createdAt: Date(timeIntervalSince1970: 20)
        )

        context.insert(olderSettings)
        context.insert(newerSettings)
        try context.save()

        try store.load(from: context)

        let persistedSettings = try context.fetch(FetchDescriptor<AppSettings>())
        XCTAssertEqual(persistedSettings.count, 1)
        XCTAssertEqual(persistedSettings[0].id, newerSettings.id)
        XCTAssertTrue(store.soundEnabled)
        XCTAssertTrue(store.vibrationEnabled)
        XCTAssertTrue(store.screenAlwaysOn)
        XCTAssertEqual(store.selectedSound, AppSound.tone.identifier)
        XCTAssertEqual(store.lastProgramID, newerID)
    }

    func testLoadNormalizesLegacyPersistedSoundValueToStableIdentifier() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = AppSettingsStore()
        let settings = AppSettings(selectedSound: "叮叮叮")

        context.insert(settings)
        try context.save()

        try store.load(from: context)

        let persistedSettings = try context.fetch(FetchDescriptor<AppSettings>())
        XCTAssertEqual(store.selectedSound, AppSound.chime.identifier)
        XCTAssertEqual(persistedSettings.first?.selectedSound, AppSound.chime.identifier)
    }

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([Program.self, TrainingRecord.self, AppSettings.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: configuration)
    }
}

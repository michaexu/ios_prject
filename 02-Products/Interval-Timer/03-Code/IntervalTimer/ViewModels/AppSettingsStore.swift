import Combine
import Foundation
import SwiftData

@MainActor
final class AppSettingsStore: ObservableObject {
    @Published var soundEnabled = true
    @Published var vibrationEnabled = true
    @Published var screenAlwaysOn = true
    @Published var selectedSound = AppSettings.defaultSound
    @Published var lastProgramID: UUID?

    private var persistedSettings: AppSettings?

    var timerReminderSettings: TimerReminderSettings {
        TimerReminderSettings(
            soundEnabled: soundEnabled,
            vibrationEnabled: vibrationEnabled,
            screenAlwaysOn: screenAlwaysOn,
            selectedSound: selectedSound
        )
    }

    func load(from context: ModelContext) throws {
        let settings = try fetchOrCreateSettings(in: context)
        apply(settings)
    }

    func setSoundEnabled(_ value: Bool, in context: ModelContext) throws {
        let settings = try fetchOrCreateSettings(in: context)
        settings.soundEnabled = value
        try context.save()
        apply(settings)
    }

    func setVibrationEnabled(_ value: Bool, in context: ModelContext) throws {
        let settings = try fetchOrCreateSettings(in: context)
        settings.vibrationEnabled = value
        try context.save()
        apply(settings)
    }

    func setScreenAlwaysOn(_ value: Bool, in context: ModelContext) throws {
        let settings = try fetchOrCreateSettings(in: context)
        settings.screenAlwaysOn = value
        try context.save()
        apply(settings)
    }

    func setSelectedSound(_ value: String, in context: ModelContext) throws {
        let settings = try fetchOrCreateSettings(in: context)
        settings.selectedSound = value
        try context.save()
        apply(settings)
    }

    func setLastProgramID(_ value: UUID?, in context: ModelContext) throws {
        let settings = try fetchOrCreateSettings(in: context)
        settings.lastProgramID = value
        try context.save()
        apply(settings)
    }

    private func fetchOrCreateSettings(in context: ModelContext) throws -> AppSettings {
        if let persistedSettings {
            return persistedSettings
        }

        var descriptor = FetchDescriptor<AppSettings>()
        descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse), SortDescriptor(\.id)]
        let settings = try context.fetch(descriptor)

        if let canonicalSettings = settings.first {
            if settings.count > 1 {
                for duplicate in settings.dropFirst() {
                    context.delete(duplicate)
                }
                try context.save()
            }

            persistedSettings = canonicalSettings
            return canonicalSettings
        }

        let defaultSettings = AppSettings()
        context.insert(defaultSettings)
        try context.save()
        persistedSettings = defaultSettings
        return defaultSettings
    }

    private func apply(_ settings: AppSettings) {
        persistedSettings = settings
        soundEnabled = settings.soundEnabled
        vibrationEnabled = settings.vibrationEnabled
        screenAlwaysOn = settings.screenAlwaysOn
        selectedSound = settings.selectedSound
        lastProgramID = settings.lastProgramID
    }
}

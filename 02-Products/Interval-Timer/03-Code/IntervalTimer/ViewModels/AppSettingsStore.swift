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
        settings.selectedSound = AppSound.normalizedIdentifier(for: value)
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
            try normalizeSelectedSoundIfNeeded(for: persistedSettings, in: context)
            return persistedSettings
        }

        let settings = try context.fetch(FetchDescriptor<AppSettings>())

        if let canonicalSettings = settings.max(by: canonicalSortComparator) {
            if settings.count > 1 {
                for duplicate in settings where duplicate.id != canonicalSettings.id {
                    context.delete(duplicate)
                }
                try context.save()
            }

            try normalizeSelectedSoundIfNeeded(for: canonicalSettings, in: context)
            persistedSettings = canonicalSettings
            return canonicalSettings
        }

        let defaultSettings = AppSettings()
        context.insert(defaultSettings)
        try context.save()
        persistedSettings = defaultSettings
        return defaultSettings
    }

    private func canonicalSortComparator(_ lhs: AppSettings, _ rhs: AppSettings) -> Bool {
        if lhs.createdAt != rhs.createdAt {
            return lhs.createdAt < rhs.createdAt
        }

        return lhs.id.uuidString < rhs.id.uuidString
    }

    private func apply(_ settings: AppSettings) {
        persistedSettings = settings
        soundEnabled = settings.soundEnabled
        vibrationEnabled = settings.vibrationEnabled
        screenAlwaysOn = settings.screenAlwaysOn
        selectedSound = AppSound.normalizedIdentifier(for: settings.selectedSound)
        lastProgramID = settings.lastProgramID
    }

    private func normalizeSelectedSoundIfNeeded(for settings: AppSettings, in context: ModelContext) throws {
        let normalizedSound = AppSound.normalizedIdentifier(for: settings.selectedSound)
        guard settings.selectedSound != normalizedSound else { return }

        settings.selectedSound = normalizedSound
        try context.save()
    }
}

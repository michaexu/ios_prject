import Foundation
import SwiftData

@Model
final class AppSettings {
    static let defaultSound = "嘀嘀嘀"

    var id: UUID
    var soundEnabled: Bool
    var vibrationEnabled: Bool
    var screenAlwaysOn: Bool
    var selectedSound: String
    var lastProgramID: UUID?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        soundEnabled: Bool = true,
        vibrationEnabled: Bool = true,
        screenAlwaysOn: Bool = true,
        selectedSound: String = AppSettings.defaultSound,
        lastProgramID: UUID? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.soundEnabled = soundEnabled
        self.vibrationEnabled = vibrationEnabled
        self.screenAlwaysOn = screenAlwaysOn
        self.selectedSound = selectedSound
        self.lastProgramID = lastProgramID
        self.createdAt = createdAt
    }
}

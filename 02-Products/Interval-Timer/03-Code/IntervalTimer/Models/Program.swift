// Program.swift
// 数据模型 - 训练方案

import Foundation
import SwiftData

// MARK: - 训练方案模型
@Model
class Program {
    var id: UUID
    var name: String
    var workDuration: Int  // 训练时间（秒）
    var restDuration: Int  // 休息时间（秒）
    var rounds: Int        // 循环次数
    var isPreset: Bool     // 是否预设方案
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, workDuration: Int, restDuration: Int, rounds: Int, isPreset: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.workDuration = workDuration
        self.restDuration = restDuration
        self.rounds = rounds
        self.isPreset = isPreset
        self.createdAt = createdAt
    }
    
    // 计算总时长（秒）
    var totalDuration: Int {
        return (workDuration + restDuration) * rounds - restDuration
    }
    
    // 格式化总时长
    var formattedTotalDuration: String {
        Self.mmss(totalDuration)
    }

    var formattedWorkDuration: String {
        Self.mmss(workDuration)
    }

    var formattedRestDuration: String {
        Self.mmss(restDuration)
    }

    var formattedTotalWorkDuration: String {
        Self.mmss(workDuration * rounds)
    }

    var formattedTotalRestDuration: String {
        Self.mmss(restDuration * max(rounds - 1, 0))
    }

    var displayName: String {
        displayName(preferredLanguages: Locale.preferredLanguages)
    }

    func displayName(preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        guard let localizationKey = presetLocalizationKey else {
            return name
        }

        return AppLocalization.text(localizationKey, preferredLanguages: preferredLanguages)
    }

    private var presetLocalizationKey: String? {
        Self.presetLocalizationKey(for: id)
    }

    private static func mmss(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - 预设方案
extension Program {
    private static func preset(
        id: String,
        name: String,
        workDuration: Int,
        restDuration: Int,
        rounds: Int
    ) -> Program {
        Program(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            workDuration: workDuration,
            restDuration: restDuration,
            rounds: rounds,
            isPreset: true,
            createdAt: Date(timeIntervalSince1970: 0)
        )
    }

    static func localizedName(
        for programID: UUID,
        fallbackName: String,
        preferredLanguages: [String] = Locale.preferredLanguages
    ) -> String {
        guard let presetProgram = presetPrograms.first(where: { $0.id == programID }) else {
            return fallbackName
        }

        return presetProgram.displayName(preferredLanguages: preferredLanguages)
    }

    private static func presetLocalizationKey(for id: UUID) -> String? {
        switch id.uuidString.uppercased() {
        case "00000000-0000-0000-0000-000000000001":
            return "preset.tabata"
        case "00000000-0000-0000-0000-000000000002":
            return "preset.seven_minute"
        case "00000000-0000-0000-0000-000000000003":
            return "preset.beginner_hiit"
        case "00000000-0000-0000-0000-000000000004":
            return "preset.advanced_hiit"
        case "00000000-0000-0000-0000-000000000005":
            return "preset.custom"
        default:
            return nil
        }
    }

    static let presetPrograms: [Program] = [
        preset(id: "00000000-0000-0000-0000-000000000001", name: "Tabata", workDuration: 20, restDuration: 10, rounds: 8),
        preset(id: "00000000-0000-0000-0000-000000000002", name: "7-Minute Workout", workDuration: 30, restDuration: 10, rounds: 12),
        preset(id: "00000000-0000-0000-0000-000000000003", name: "Beginner HIIT", workDuration: 45, restDuration: 15, rounds: 10),
        preset(id: "00000000-0000-0000-0000-000000000004", name: "Advanced HIIT", workDuration: 60, restDuration: 20, rounds: 15),
        preset(id: "00000000-0000-0000-0000-000000000005", name: "Custom", workDuration: 30, restDuration: 30, rounds: 5)
    ]
}

// MARK: - 训练记录模型
@Model
class TrainingRecord {
    var id: UUID
    var programId: UUID
    var programName: String
    var date: Date
    var totalDuration: Int     // 总时长（秒）
    var completedRounds: Int   // 完成的循环数
    var totalWorkDuration: Int // 总训练时长（秒）
    
    init(id: UUID = UUID(), programId: UUID, programName: String, date: Date = Date(), totalDuration: Int, completedRounds: Int, totalWorkDuration: Int) {
        self.id = id
        self.programId = programId
        self.programName = programName
        self.date = date
        self.totalDuration = totalDuration
        self.completedRounds = completedRounds
        self.totalWorkDuration = totalWorkDuration
    }
}

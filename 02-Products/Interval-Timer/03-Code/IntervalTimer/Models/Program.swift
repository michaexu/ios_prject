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
        let minutes = totalDuration / 60
        let seconds = totalDuration % 60
        return String(format: "%02d:%02d", minutes, seconds)
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

    static let presetPrograms: [Program] = [
        preset(id: "00000000-0000-0000-0000-000000000001", name: "Tabata", workDuration: 20, restDuration: 10, rounds: 8),
        preset(id: "00000000-0000-0000-0000-000000000002", name: "7分钟训练", workDuration: 30, restDuration: 10, rounds: 12),
        preset(id: "00000000-0000-0000-0000-000000000003", name: "HIIT 初级", workDuration: 45, restDuration: 15, rounds: 10),
        preset(id: "00000000-0000-0000-0000-000000000004", name: "HIIT 高级", workDuration: 60, restDuration: 20, rounds: 15),
        preset(id: "00000000-0000-0000-0000-000000000005", name: "自定义", workDuration: 30, restDuration: 30, rounds: 5)
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

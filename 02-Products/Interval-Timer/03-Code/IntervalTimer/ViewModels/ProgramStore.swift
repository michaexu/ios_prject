import Combine
import Foundation
import SwiftData

@MainActor
final class ProgramStore: ObservableObject {
    @Published private(set) var customPrograms: [Program] = []

    let presetPrograms = Program.presetPrograms

    func program(withID id: UUID) -> Program? {
        customPrograms.first(where: { $0.id == id }) ?? presetPrograms.first(where: { $0.id == id })
    }

    func loadCustomPrograms(from context: ModelContext) throws {
        var descriptor = FetchDescriptor<Program>(
            predicate: #Predicate<Program> { program in
                program.isPreset == false
            }
        )
        descriptor.sortBy = [SortDescriptor(\.createdAt)]
        customPrograms = try context.fetch(descriptor)
    }

    func save(_ program: Program, in context: ModelContext) throws {
        if let existingProgram = try fetchCustomProgram(id: program.id, from: context) {
            existingProgram.name = program.name
            existingProgram.workDuration = program.workDuration
            existingProgram.restDuration = program.restDuration
            existingProgram.rounds = program.rounds
            existingProgram.createdAt = program.createdAt
        } else {
            program.isPreset = false
            context.insert(program)
        }

        try context.save()
        try loadCustomPrograms(from: context)
    }

    func delete(_ program: Program, from context: ModelContext) throws {
        if let existingProgram = try fetchCustomProgram(id: program.id, from: context) {
            context.delete(existingProgram)
            try context.save()
        }

        customPrograms.removeAll { $0.id == program.id }
    }

    private func fetchCustomProgram(id: UUID, from context: ModelContext) throws -> Program? {
        let descriptor = FetchDescriptor<Program>(
            predicate: #Predicate<Program> { program in
                program.id == id && program.isPreset == false
            }
        )
        return try context.fetch(descriptor).first
    }
}

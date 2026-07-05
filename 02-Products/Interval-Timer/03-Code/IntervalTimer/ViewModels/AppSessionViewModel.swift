import Combine
import Foundation

enum AppTab: Hashable {
    case home
    case timer
    case programs
    case stats
    case settings
}

@MainActor
final class AppSessionViewModel: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published private(set) var activeProgram: Program?
    @Published private(set) var lastSelectedProgram: Program?

    let timerManager = TimerManager()

    func start(program: Program) {
        timerManager.setup(program: program)
        activeProgram = program
        lastSelectedProgram = program
        selectedTab = .timer
    }

    func restoreLastSelectedProgram(_ program: Program) {
        lastSelectedProgram = program
    }

    func endSession() {
        timerManager.stop()
        activeProgram = nil
        timerManager.clear()
    }
}

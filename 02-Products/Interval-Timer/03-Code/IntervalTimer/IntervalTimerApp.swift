// IntervalTimerApp.swift
// 主应用入口

import SwiftData
import SwiftUI
import UIKit

@main
struct IntervalTimerApp: App {
    @StateObject private var appSession = AppSessionViewModel()
    @StateObject private var settingsStore = AppSettingsStore()
    @StateObject private var programStore = ProgramStore()

    private let sharedModelContainer: ModelContainer = {
        let schema = Schema([Program.self, TrainingRecord.self, AppSettings.self])
        return try! ModelContainer(for: schema)
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
                .environmentObject(appSession)
                .environmentObject(settingsStore)
                .environmentObject(programStore)
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - 主界面（TabView）
struct MainTabView: View {
    @EnvironmentObject private var appSession: AppSessionViewModel
    @EnvironmentObject private var settingsStore: AppSettingsStore
    @EnvironmentObject private var programStore: ProgramStore
    @Environment(\.modelContext) private var modelContext
    @State private var bootstrapErrorMessage: String?
    
    var body: some View {
        TabView(selection: $appSession.selectedTab) {
            HomeView()
                .tag(AppTab.home)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(AppLocalization.text("tabs.home"))
                }
            
            TimerView()
                .tag(AppTab.timer)
                .tabItem {
                    Image(systemName: "timer")
                    Text(AppLocalization.text("tabs.timer"))
                }
            
            ProgramsView()
                .tag(AppTab.programs)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text(AppLocalization.text("tabs.programs"))
                }
            
            StatsView()
                .tag(AppTab.stats)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text(AppLocalization.text("tabs.stats"))
                }
            
            SettingsView()
                .tag(AppTab.settings)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text(AppLocalization.text("tabs.settings"))
                }
        }
        .accentColor(.neonBlue)
        .onAppear {
            // 设置 TabBar 外观
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.backgroundLight)
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .task {
            do {
                try settingsStore.load(from: modelContext)
                try programStore.loadCustomPrograms(from: modelContext)
                if let lastProgramID = settingsStore.lastProgramID,
                   let program = programStore.program(withID: lastProgramID) {
                    appSession.restoreLastSelectedProgram(program)
                }
            } catch {
                bootstrapErrorMessage = AppLocalization.text("app.restore_failed.message")
            }
        }
        .alert(AppLocalization.text("app.restore_failed.title"), isPresented: bootstrapErrorAlertBinding) {
            Button(AppLocalization.text("common.ok"), role: .cancel) {
                bootstrapErrorMessage = nil
            }
        } message: {
            Text(bootstrapErrorMessage ?? AppLocalization.text("common.try_again_later"))
        }
    }

    private var bootstrapErrorAlertBinding: Binding<Bool> {
        Binding(
            get: { bootstrapErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    bootstrapErrorMessage = nil
                }
            }
        )
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppSessionViewModel())
        .environmentObject(AppSettingsStore())
        .environmentObject(ProgramStore())
}

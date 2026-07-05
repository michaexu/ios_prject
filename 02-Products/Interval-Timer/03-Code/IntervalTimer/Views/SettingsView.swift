// SettingsView.swift
// 设置页面

import SwiftData
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settingsStore: AppSettingsStore
    @Environment(\.modelContext) private var modelContext
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundDeep
                    .edgesIgnoringSafeArea(.all)
                
                List {
                    Section(header: Text(AppLocalization.text("settings.reminders")).foregroundColor(.textPrimary)) {
                        Toggle(isOn: soundBinding) {
                            HStack {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(.neonBlue)
                                    .frame(width: 24)
                                Text(AppLocalization.text("settings.sound"))
                                    .foregroundColor(.textPrimary)
                            }
                        }
                        .tint(.neonBlue)
                        
                        Toggle(isOn: vibrationBinding) {
                            HStack {
                                Image(systemName: "iphone.radiowaves.left.and.right")
                                    .foregroundColor(.neonGreen)
                                    .frame(width: 24)
                                Text(AppLocalization.text("settings.vibration"))
                                    .foregroundColor(.textPrimary)
                            }
                        }
                        .tint(.neonBlue)
                        
                        NavigationLink(destination: SoundSelectionView()) {
                            HStack {
                                Image(systemName: "music.note")
                                    .foregroundColor(.neonPurple)
                                    .frame(width: 24)
                                Text(AppLocalization.text("settings.sound_selection"))
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                Text(AppSound.displayName(for: settingsStore.selectedSound))
                                    .foregroundColor(.textSecondary)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.textDisabled)
                            }
                        }
                    }
                    .listRowBackground(Color.backgroundLight)
                    
                    Section(header: Text(AppLocalization.text("settings.display")).foregroundColor(.textPrimary)) {
                        Toggle(isOn: screenAlwaysOnBinding) {
                            HStack {
                                Image(systemName: "display")
                                    .foregroundColor(.neonBlue)
                                    .frame(width: 24)
                                Text(AppLocalization.text("settings.screen_awake"))
                                    .foregroundColor(.textPrimary)
                            }
                        }
                        .tint(.neonBlue)
                    }
                    .listRowBackground(Color.backgroundLight)
                    
                    Section(header: Text(AppLocalization.text("settings.about")).foregroundColor(.textPrimary)) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.neonBlue)
                                .frame(width: 24)
                            Text(AppLocalization.text("settings.version"))
                                .foregroundColor(.textPrimary)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.textSecondary)
                        }
                        
                        NavigationLink(destination: PrivacyPolicyView()) {
                            HStack {
                                Image(systemName: "lock.shield")
                                    .foregroundColor(.neonGreen)
                                    .frame(width: 24)
                                Text(AppLocalization.text("settings.privacy_policy"))
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }
                    .listRowBackground(Color.backgroundLight)
                }
                .listStyle(PlainListStyle())
                .background(Color.backgroundDeep)
            }
            .navigationBarTitle(AppLocalization.text("settings.title"), displayMode: .large)
            .task {
                do {
                    try settingsStore.load(from: modelContext)
                } catch {
                    errorMessage = AppLocalization.text("settings.load_failed")
                }
            }
            .alert(AppLocalization.text("settings.save_failed.title"), isPresented: errorAlertBinding) {
                Button(AppLocalization.text("common.ok"), role: .cancel) {}
            } message: {
                Text(errorMessage ?? AppLocalization.text("common.try_again_later"))
            }
        }
        .preferredColorScheme(.dark)
    }

    private var soundBinding: Binding<Bool> {
        Binding(
            get: { settingsStore.soundEnabled },
            set: { newValue in
                do {
                    try settingsStore.setSoundEnabled(newValue, in: modelContext)
                } catch {
                    errorMessage = AppLocalization.text("settings.save_failed.sound")
                }
            }
        )
    }

    private var vibrationBinding: Binding<Bool> {
        Binding(
            get: { settingsStore.vibrationEnabled },
            set: { newValue in
                do {
                    try settingsStore.setVibrationEnabled(newValue, in: modelContext)
                } catch {
                    errorMessage = AppLocalization.text("settings.save_failed.vibration")
                }
            }
        )
    }

    private var screenAlwaysOnBinding: Binding<Bool> {
        Binding(
            get: { settingsStore.screenAlwaysOn },
            set: { newValue in
                do {
                    try settingsStore.setScreenAlwaysOn(newValue, in: modelContext)
                } catch {
                    errorMessage = AppLocalization.text("settings.save_failed.screen")
                }
            }
        )
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )
    }
}

struct SoundSelectionView: View {
    @EnvironmentObject private var settingsStore: AppSettingsStore
    @Environment(\.modelContext) private var modelContext
    @State private var errorMessage: String?
    let sounds = AppSound.allCases
    
    var body: some View {
        ZStack {
            Color.backgroundDeep
                .edgesIgnoringSafeArea(.all)
            
            List {
                ForEach(sounds, id: \.identifier) { sound in
                    Button(action: {
                        do {
                            try settingsStore.setSelectedSound(sound.identifier, in: modelContext)
                        } catch {
                            errorMessage = AppLocalization.text("settings.save_failed.sound_selection")
                        }
                    }) {
                        HStack {
                            Text(AppLocalization.text(sound.localizationKey))
                                .foregroundColor(.textPrimary)
                            
                            Spacer()
                            
                            if settingsStore.selectedSound == sound.identifier {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.neonBlue)
                            }
                        }
                    }
                    .listRowBackground(Color.backgroundLight)
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.backgroundDeep)
        }
        .navigationBarTitle(AppLocalization.text("settings.sound_picker.title"), displayMode: .inline)
        .preferredColorScheme(.dark)
        .task {
            do {
                try settingsStore.load(from: modelContext)
            } catch {
                errorMessage = AppLocalization.text("settings.sound_picker.load_failed")
            }
        }
        .alert(AppLocalization.text("settings.save_failed.title"), isPresented: errorAlertBinding) {
            Button(AppLocalization.text("common.ok"), role: .cancel) {}
        } message: {
            Text(errorMessage ?? AppLocalization.text("common.try_again_later"))
        }
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            Color.backgroundDeep
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text(AppLocalization.text("privacy.title"))
                        .font(.appTitle)
                        .foregroundColor(.textPrimary)
                    
                    Text(AppLocalization.text("privacy.body"))
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                        .lineSpacing(4)
                }
                .padding(Spacing.md)
            }
        }
        .navigationBarTitle(AppLocalization.text("privacy.title"), displayMode: .inline)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppSettingsStore())
}

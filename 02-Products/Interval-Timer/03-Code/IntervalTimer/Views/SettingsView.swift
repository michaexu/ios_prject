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
                    Section(header: Text("提醒设置").foregroundColor(.textPrimary)) {
                        Toggle(isOn: soundBinding) {
                            HStack {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(.neonBlue)
                                    .frame(width: 24)
                                Text("声音提醒")
                                    .foregroundColor(.textPrimary)
                            }
                        }
                        .tint(.neonBlue)
                        
                        Toggle(isOn: vibrationBinding) {
                            HStack {
                                Image(systemName: "iphone.radiowaves.left.and.right")
                                    .foregroundColor(.neonGreen)
                                    .frame(width: 24)
                                Text("震动提醒")
                                    .foregroundColor(.textPrimary)
                            }
                        }
                        .tint(.neonBlue)
                        
                        NavigationLink(destination: SoundSelectionView()) {
                            HStack {
                                Image(systemName: "music.note")
                                    .foregroundColor(.neonPurple)
                                    .frame(width: 24)
                                Text("提示音")
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                Text(settingsStore.selectedSound)
                                    .foregroundColor(.textSecondary)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.textDisabled)
                            }
                        }
                    }
                    .listRowBackground(Color.backgroundLight)
                    
                    Section(header: Text("显示设置").foregroundColor(.textPrimary)) {
                        Toggle(isOn: screenAlwaysOnBinding) {
                            HStack {
                                Image(systemName: "display")
                                    .foregroundColor(.neonBlue)
                                    .frame(width: 24)
                                Text("屏幕常亮")
                                    .foregroundColor(.textPrimary)
                            }
                        }
                        .tint(.neonBlue)
                    }
                    .listRowBackground(Color.backgroundLight)
                    
                    Section(header: Text("关于").foregroundColor(.textPrimary)) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.neonBlue)
                                .frame(width: 24)
                            Text("版本")
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
                                Text("隐私政策")
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }
                    .listRowBackground(Color.backgroundLight)
                }
                .listStyle(PlainListStyle())
                .background(Color.backgroundDeep)
            }
            .navigationBarTitle("设置", displayMode: .large)
            .task {
                do {
                    try settingsStore.load(from: modelContext)
                } catch {
                    errorMessage = "无法加载设置。"
                }
            }
            .alert("无法保存设置", isPresented: errorAlertBinding) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "请稍后重试。")
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
                    errorMessage = "声音提醒设置未能保存。"
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
                    errorMessage = "震动提醒设置未能保存。"
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
                    errorMessage = "屏幕常亮设置未能保存。"
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
    let sounds = ["嘀嘀嘀", "叮叮叮", "嘟嘟嘟"]
    
    var body: some View {
        ZStack {
            Color.backgroundDeep
                .edgesIgnoringSafeArea(.all)
            
            List {
                ForEach(0..<sounds.count, id: \.self) { index in
                    Button(action: {
                        do {
                            try settingsStore.setSelectedSound(sounds[index], in: modelContext)
                        } catch {
                            errorMessage = "提示音设置未能保存。"
                        }
                    }) {
                        HStack {
                            Text(sounds[index])
                                .foregroundColor(.textPrimary)
                            
                            Spacer()
                            
                            if settingsStore.selectedSound == sounds[index] {
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
        .navigationBarTitle("提示音", displayMode: .inline)
        .preferredColorScheme(.dark)
        .task {
            do {
                try settingsStore.load(from: modelContext)
            } catch {
                errorMessage = "无法加载提示音设置。"
            }
        }
        .alert("无法保存设置", isPresented: errorAlertBinding) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "请稍后重试。")
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
                    Text("隐私政策")
                        .font(.appTitle)
                        .foregroundColor(.textPrimary)
                    
                    Text("本应用尊重并保护所有使用服务的用户隐私权...")
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                        .lineSpacing(4)
                }
                .padding(Spacing.md)
            }
        }
        .navigationBarTitle("隐私政策", displayMode: .inline)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppSettingsStore())
}

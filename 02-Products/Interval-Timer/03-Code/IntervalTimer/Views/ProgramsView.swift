// ProgramsView.swift
// 方案页面 - 自定义和预设方案列表

import SwiftData
import SwiftUI

struct ProgramsView: View {
    @EnvironmentObject private var appSession: AppSessionViewModel
    @EnvironmentObject private var programStore: ProgramStore
    @EnvironmentObject private var settingsStore: AppSettingsStore
    @Environment(\.modelContext) private var modelContext
    @State private var showEditor = false
    @State private var editingProgram: Program?
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundDeep
                    .edgesIgnoringSafeArea(.all)
                
                List {
                    Section(header: Text("我的方案").foregroundColor(.textPrimary)) {
                        ForEach(programStore.customPrograms) { program in
                            ProgramRow(
                                program: program,
                                action: { startProgram(program) },
                                onEdit: {
                                    editingProgram = program
                                    showEditor = true
                                }
                            )
                        }
                        .onDelete(perform: deletePrograms)
                        
                        Button(action: {
                            editingProgram = nil
                            showEditor = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.neonBlue)
                                Text("新建方案")
                                    .foregroundColor(.neonBlue)
                            }
                        }
                    }
                    
                    Section(header: Text("预设方案").foregroundColor(.textPrimary)) {
                        ForEach(programStore.presetPrograms) { program in
                            ProgramRow(
                                program: program,
                                action: { startProgram(program) },
                                onEdit: nil
                            )
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.backgroundDeep)
            }
            .navigationBarTitle("训练方案", displayMode: .large)
            .navigationBarItems(trailing: Button(action: {
                editingProgram = nil
                showEditor = true
            }) {
                Image(systemName: "plus")
                    .foregroundColor(.neonBlue)
            })
            .sheet(isPresented: $showEditor) {
                ProgramEditorView(program: editingProgram) { program in
                    try programStore.save(program, in: modelContext)
                }
            }
            .task {
                do {
                    try programStore.loadCustomPrograms(from: modelContext)
                } catch {
                    errorMessage = "无法加载训练方案。"
                }
            }
            .alert("无法保存数据", isPresented: errorAlertBinding) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "请稍后重试。")
            }
        }
        .preferredColorScheme(.dark)
    }

    private func deletePrograms(at offsets: IndexSet) {
        let programsToDelete = offsets.compactMap { index in
            programStore.customPrograms.indices.contains(index) ? programStore.customPrograms[index] : nil
        }

        for program in programsToDelete {
            do {
                try programStore.delete(program, from: modelContext)
            } catch {
                errorMessage = "无法删除训练方案。"
                break
            }
        }
    }

    private func startProgram(_ program: Program) {
        appSession.start(program: program)

        do {
            try settingsStore.setLastProgramID(program.id, in: modelContext)
        } catch {
            errorMessage = "无法保存最近使用的训练方案。"
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

struct ProgramRow: View {
    let program: Program
    let action: () -> Void
    let onEdit: (() -> Void)?
    
    var body: some View {
        HStack {
            Button(action: action) {
                rowContent
            }

            if let onEdit {
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle")
                        .font(.title3)
                        .foregroundColor(.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .listRowBackground(Color.backgroundLight)
    }

    private var rowContent: some View {
        HStack {
            Text(program.isPreset ? "🔥" : "🏋️")
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(program.name)
                    .font(.appBody)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text("\(program.workDuration)s 训练 / \(program.restDuration)s 休息")
                    .font(.appSmall)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Text("\(program.rounds) 轮")
                .font(.appCaption)
                .foregroundColor(.textSecondary)
            
            Image(systemName: "play.circle.fill")
                .font(.title3)
                .foregroundColor(.neonBlue)
        }
        .padding(.vertical, Spacing.sm)
    }
}

struct ProgramEditorView: View {
    let program: Program?
    let onSave: (Program) throws -> Void
    @State private var name: String = ""
    @State private var workDuration: Int = 30
    @State private var restDuration: Int = 30
    @State private var rounds: Int = 5
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundDeep
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("方案名称")
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                            
                            TextField("输入方案名称...", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .colorScheme(.dark)
                        }
                        
                        TimeSelector(title: "训练时间", duration: $workDuration)
                        TimeSelector(title: "休息时间", duration: $restDuration)
                        RoundSelector(rounds: $rounds)
                        PreviewCard(workDuration: workDuration, restDuration: restDuration, rounds: rounds)
                        
                        Spacer()
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationBarTitle(program == nil ? "新建方案" : "编辑方案", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    saveProgram()
                }
            )
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if let program = program {
                name = program.name
                workDuration = program.workDuration
                restDuration = program.restDuration
                rounds = program.rounds
            }
        }
        .alert("无法保存训练方案", isPresented: errorAlertBinding) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "请稍后重试。")
        }
    }
    
    private func saveProgram() {
        let savedProgram = Program(
            id: program?.id ?? UUID(),
            name: name,
            workDuration: workDuration,
            restDuration: restDuration,
            rounds: rounds,
            isPreset: program?.isPreset ?? false,
            createdAt: program?.createdAt ?? Date()
        )

        do {
            try onSave(savedProgram)
            presentationMode.wrappedValue.dismiss()
        } catch {
            errorMessage = "训练方案未能保存。"
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

struct TimeSelector: View {
    let title: String
    @Binding var duration: Int
    
    var body: some View {
        VStack {
            Text(title)
                .font(.appCaption)
                .foregroundColor(.textSecondary)
            
            HStack {
                Button(action: { if duration > 1 { duration -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.neonBlue)
                }
                
                Text(formatDuration(duration))
                    .font(.appTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                    .frame(width: 100)
                
                Button(action: { if duration < 5999 { duration += 1 } }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.neonBlue)
                }
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity)
        .background(Color.backgroundLight)
        .cornerRadius(CornerRadius.medium)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

struct RoundSelector: View {
    @Binding var rounds: Int
    
    var body: some View {
        VStack {
            Text("循环次数")
                .font(.appCaption)
                .foregroundColor(.textSecondary)
            
            HStack {
                Button(action: { if rounds > 1 { rounds -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.neonBlue)
                }
                
                Text("\(rounds)")
                    .font(.appTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                    .frame(width: 100)
                
                Button(action: { if rounds < 99 { rounds += 1 } }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.neonBlue)
                }
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity)
        .background(Color.backgroundLight)
        .cornerRadius(CornerRadius.medium)
    }
}

struct PreviewCard: View {
    let workDuration: Int
    let restDuration: Int
    let rounds: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("预览")
                .font(.appCaption)
                .foregroundColor(.textSecondary)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text("总时长：")
                    Text(formatTotalDuration())
                        .foregroundColor(.neonBlue)
                }
                
                HStack {
                    Text("训练：")
                    Text("\(formatSeconds(workDuration * rounds))")
                        .foregroundColor(.neonBlue)
                }
                
                HStack {
                    Text("休息：")
                    Text("\(formatSeconds(restDuration * (rounds - 1)))")
                        .foregroundColor(.neonGreen)
                }
            }
            .font(.appSmall)
            .foregroundColor(.textSecondary)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundLight)
        .cornerRadius(CornerRadius.medium)
    }
    
    private func formatTotalDuration() -> String {
        let total = (workDuration + restDuration) * rounds - restDuration
        return formatSeconds(total)
    }
    
    private func formatSeconds(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d 分钟 %d 秒", mins, secs)
    }
}

#Preview {
    ProgramsView()
        .environmentObject(AppSessionViewModel())
        .environmentObject(AppSettingsStore())
        .environmentObject(ProgramStore())
}

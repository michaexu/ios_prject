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
                    Section(header: Text(AppLocalization.text("programs.my_programs")).foregroundColor(.textPrimary)) {
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
                                Text(AppLocalization.text("programs.new_program"))
                                    .foregroundColor(.neonBlue)
                            }
                        }
                    }
                    
                    Section(header: Text(AppLocalization.text("programs.preset_programs")).foregroundColor(.textPrimary)) {
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
            .navigationBarTitle(AppLocalization.text("programs.title"), displayMode: .large)
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
                    errorMessage = AppLocalization.text("programs.load_failed")
                }
            }
            .alert(AppLocalization.text("programs.save_failed.title"), isPresented: errorAlertBinding) {
                Button(AppLocalization.text("common.ok"), role: .cancel) {}
            } message: {
                Text(errorMessage ?? AppLocalization.text("common.try_again_later"))
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
                errorMessage = AppLocalization.text("programs.delete_failed")
                break
            }
        }
    }

    private func startProgram(_ program: Program) {
        appSession.start(program: program)

        do {
            try settingsStore.setLastProgramID(program.id, in: modelContext)
        } catch {
            errorMessage = AppLocalization.text("programs.last_program_failed")
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
    @State private var showDetail = false

    var body: some View {
        HStack {
            Button(action: action) {
                rowContent
            }

            Button(action: { showDetail = true }) {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundColor(.neonPurple)
            }
            .buttonStyle(.plain)

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
        .sheet(isPresented: $showDetail) {
            ProgramDetailView(program: program)
        }
    }

    private var rowContent: some View {
        HStack {
            Text(program.isPreset ? "🔥" : "🏋️")
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(program.displayName)
                    .font(.appBody)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text(AppTextFormatters.workRestSummary(work: program.workDuration, rest: program.restDuration))
                    .font(.appSmall)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Text(AppTextFormatters.rounds(program.rounds))
                .font(.appCaption)
                .foregroundColor(.textSecondary)
            
            Image(systemName: "play.circle.fill")
                .font(.title3)
                .foregroundColor(.neonBlue)
        }
        .padding(.vertical, Spacing.sm)
    }
}

struct ProgramDetailView: View {
    let program: Program
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundDeep
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        headerCard
                        paramsSection
                        summarySection
                        metaSection
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationBarTitle(AppLocalization.text("programs.detail.title"), displayMode: .inline)
            .navigationBarItems(trailing: Button(AppLocalization.text("common.done")) {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .preferredColorScheme(.dark)
    }

    private var headerCard: some View {
        VStack(spacing: Spacing.sm) {
            Text(program.isPreset ? "🔥" : "🏋️")
                .font(.system(size: 48))

            Text(program.displayName)
                .font(.appTitle)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)

            Text(program.formattedTotalDuration)
                .font(.appSubtitle)
                .foregroundColor(.neonBlue)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.lg)
        .background(Color.backgroundLight)
        .cornerRadius(CornerRadius.medium)
    }

    private var paramsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(AppLocalization.text("programs.detail.parameters"))
                .font(.appSubtitle)
                .foregroundColor(.textSecondary)

            detailRow(label: AppLocalization.text("programs.detail.work_duration"), value: program.formattedWorkDuration, color: .neonBlue)
            detailRow(label: AppLocalization.text("programs.detail.rest_duration"), value: program.formattedRestDuration, color: .neonGreen)
            detailRow(label: AppLocalization.text("programs.detail.rounds"), value: AppTextFormatters.rounds(program.rounds), color: .neonPurple)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundLight)
        .cornerRadius(CornerRadius.medium)
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(AppLocalization.text("programs.detail.duration_summary"))
                .font(.appSubtitle)
                .foregroundColor(.textSecondary)

            detailRow(label: AppLocalization.text("programs.detail.total_duration"), value: program.formattedTotalDuration, color: .neonBlue)
            detailRow(label: AppLocalization.text("programs.detail.total_work"), value: program.formattedTotalWorkDuration, color: .neonBlue)
            detailRow(label: AppLocalization.text("programs.detail.total_rest"), value: program.formattedTotalRestDuration, color: .neonGreen)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundLight)
        .cornerRadius(CornerRadius.medium)
    }

    private var metaSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(AppLocalization.text("programs.detail.other_info"))
                .font(.appSubtitle)
                .foregroundColor(.textSecondary)

            detailRow(
                label: AppLocalization.text("programs.detail.program_type"),
                value: AppLocalization.text(program.isPreset ? "program.type.preset" : "program.type.custom"),
                color: .textPrimary
            )

            if !program.isPreset {
                detailRow(label: AppLocalization.text("programs.detail.created_at"), value: formattedCreatedAt, color: .textPrimary)
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundLight)
        .cornerRadius(CornerRadius.medium)
    }

    private func detailRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.appBody)
                .foregroundColor(.textSecondary)

            Spacer()

            Text(value)
                .font(.appBody)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }

    private var formattedCreatedAt: String {
        AppTextFormatters.localizedDateTime(program.createdAt)
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
                            Text(AppLocalization.text("programs.editor.name"))
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                            
                            TextField(AppLocalization.text("programs.editor.placeholder"), text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .colorScheme(.dark)
                        }
                        
                        TimeSelector(title: AppLocalization.text("programs.editor.work_time"), duration: $workDuration)
                        TimeSelector(title: AppLocalization.text("programs.editor.rest_time"), duration: $restDuration)
                        RoundSelector(rounds: $rounds)
                        PreviewCard(workDuration: workDuration, restDuration: restDuration, rounds: rounds)
                        
                        Spacer()
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationBarTitle(
                program == nil ? AppLocalization.text("programs.editor.new_title") : AppLocalization.text("programs.editor.edit_title"),
                displayMode: .inline
            )
            .navigationBarItems(
                leading: Button(AppLocalization.text("common.cancel")) {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(AppLocalization.text("common.save")) {
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
        .alert(AppLocalization.text("programs.editor.save_failed.title"), isPresented: errorAlertBinding) {
            Button(AppLocalization.text("common.ok"), role: .cancel) {}
        } message: {
            Text(errorMessage ?? AppLocalization.text("common.try_again_later"))
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
            errorMessage = AppLocalization.text("programs.editor.save_failed.message")
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
            Text(AppLocalization.text("programs.editor.rounds"))
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
            Text(AppLocalization.text("programs.editor.preview"))
                .font(.appCaption)
                .foregroundColor(.textSecondary)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(AppLocalization.text("programs.preview.total_duration"))
                    Text(formatTotalDuration())
                        .foregroundColor(.neonBlue)
                }
                
                HStack {
                    Text(AppLocalization.text("programs.preview.total_work"))
                    Text("\(formatSeconds(workDuration * rounds))")
                        .foregroundColor(.neonBlue)
                }
                
                HStack {
                    Text(AppLocalization.text("programs.preview.total_rest"))
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
        AppTextFormatters.previewDuration(seconds)
    }
}

#Preview {
    ProgramsView()
        .environmentObject(AppSessionViewModel())
        .environmentObject(AppSettingsStore())
        .environmentObject(ProgramStore())
}

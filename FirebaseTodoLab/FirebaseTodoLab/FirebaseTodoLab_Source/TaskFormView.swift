import SwiftUI

struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: TaskStore

    let task: TodoTask?

    @State private var title: String
    @State private var details: String
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(store: TaskStore, task: TodoTask? = nil) {
        self.store = store
        self.task = task
        _title = State(initialValue: task?.title ?? "")
        _details = State(initialValue: task?.details ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task information") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $details, axis: .vertical)
                        .lineLimit(3...6)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(task == nil ? "Add Task" : "Edit Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Saving..." : "Save") {
                        Task { await saveTask() }
                    }
                    .disabled(isSaving || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveTask() async {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else { return }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            if let task {
                try await store.update(task, title: cleanTitle, details: details)
            } else {
                try await store.add(title: cleanTitle, details: details)
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

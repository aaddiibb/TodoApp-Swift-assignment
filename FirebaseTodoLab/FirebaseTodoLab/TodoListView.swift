
import SwiftUI

struct TodoListView: View {
    @ObservedObject var session: SessionStore
    let userID: String

    @StateObject private var store = TaskStore()
    @State private var showingAddTask = false
    @State private var editingTask: TodoTask?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if store.tasks.isEmpty {
                        ContentUnavailableView(
                            "No Tasks Yet",
                            systemImage: "checklist",
                            description: Text("Tap + to create your first task.")
                        )
                    } else {
                        ForEach(store.tasks) { task in
                            taskRow(task)
                        }
                    }
                } header: {
                    Text("My Tasks (\(store.tasks.count))")
                } footer: {
                    if let email = session.userEmail {
                        Text("Signed in as \(email)")
                    }
                }
            }
            .navigationTitle("My Todo List")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Log Out") {
                        session.signOut()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Task")
                }
            }
            .sheet(isPresented: $showingAddTask) {
                TaskFormView(store: store)
            }
            .sheet(item: $editingTask) { task in
                TaskFormView(store: store, task: task)
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { store.errorMessage != nil || session.errorMessage != nil },
                    set: { if !$0 {
                        store.errorMessage = nil
                        session.errorMessage = nil
                    } }
                )
            ) {
                Button("OK") {
                    store.errorMessage = nil
                    session.errorMessage = nil
                }
            } message: {
                Text(store.errorMessage ?? session.errorMessage ?? "Unknown error")
            }
        }
        .task(id: userID) {
            store.listen(for: userID)
        }
        .onDisappear {
            store.stopListening()
        }
    }

    private func taskRow(_ task: TodoTask) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                Task { await store.toggleCompleted(task) }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(task.isCompleted ? "Mark incomplete" : "Mark complete")

            Button {
                editingTask = task
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text(task.title)
                        .font(.headline)
                        .strikethrough(task.isCompleted)
                        .foregroundStyle(task.isCompleted ? .secondary : .primary)

                    if !task.details.isEmpty {
                        Text(task.details)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 5)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                Task { await store.delete(task) }
            } label: {
                Label("Delete", systemImage: "trash")
            }

            Button {
                editingTask = task
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
}

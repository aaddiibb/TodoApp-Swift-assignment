
import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

private enum TaskStoreError: LocalizedError {
    case notSignedIn

    var errorDescription: String? {
        "You must sign in before changing tasks."
    }
}

@MainActor
final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [TodoTask] = []
    @Published var errorMessage: String?

    private var listener: ListenerRegistration?
    private var listeningUserID: String?

    // Read and receive real-time updates for the currently signed-in user.
    func listen(for userID: String) {
        guard listeningUserID != userID else { return }
        stopListening()
        listeningUserID = userID

        let query = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("tasks")
            .order(by: "createdAt", descending: true)

        listener = query.addSnapshotListener { [weak self] snapshot, error in
            // The listener may call back outside the main actor.
            Task { @MainActor [weak self] in
                guard let self, self.listeningUserID == userID else { return }
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                self.tasks = snapshot?.documents.compactMap {
                    TodoTask(document: $0)
                } ?? []
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        listeningUserID = nil
        tasks = []
    }

    private func taskCollection() throws -> CollectionReference {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw TaskStoreError.notSignedIn
        }
        return Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("tasks")
    }

    // CREATE
    func add(title: String, details: String) async throws {
        let data: [String: Any] = [
            "title": title,
            "description": details,
            "isCompleted": false,
            "createdAt": Timestamp(date: Date())
        ]
        _ = try await taskCollection().addDocument(data: data)
    }

    // UPDATE title and description
    func update(_ task: TodoTask, title: String, details: String) async throws {
        try await taskCollection().document(task.id).updateData([
            "title": title,
            "description": details
        ])
    }

    // UPDATE completion state
    func toggleCompleted(_ task: TodoTask) async {
        do {
            try await taskCollection().document(task.id).updateData([
                "isCompleted": !task.isCompleted
            ])
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // DELETE
    func delete(_ task: TodoTask) async {
        do {
            try await taskCollection().document(task.id).delete()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

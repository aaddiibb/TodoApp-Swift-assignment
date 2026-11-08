import Foundation
import FirebaseFirestore

struct TodoTask: Identifiable {
    let id: String
    let title: String
    let details: String
    let isCompleted: Bool
    let createdAt: Date

    // Convert a Firestore document into a Swift value.
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let title = data["title"] as? String else { return nil }

        id = document.documentID
        self.title = title
        details = data["description"] as? String ?? ""
        isCompleted = data["isCompleted"] as? Bool ?? false
        createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? .distantPast
    }
}

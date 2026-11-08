import SwiftUI

struct ContentView: View {
    @StateObject private var session = SessionStore()

    var body: some View {
        Group {
            if session.isCheckingAuth {
                ProgressView("Checking sign-in...")
            } else if let userID = session.userID {
                TodoListView(session: session, userID: userID)
            } else {
                AuthView(session: session)
            }
        }
        .task {
            session.start()
        }
    }
}

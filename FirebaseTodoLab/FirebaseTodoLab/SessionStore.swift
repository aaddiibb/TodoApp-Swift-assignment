
import Foundation
import Combine
import FirebaseAuth

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var userID: String?
    @Published private(set) var userEmail: String?
    @Published private(set) var isCheckingAuth = true
    @Published private(set) var isBusy = false
    @Published var errorMessage: String?

    private var authListener: AuthStateDidChangeListenerHandle?

    // Firebase restores a previously signed-in session asynchronously.
    // The listener handles both startup and subsequent login/logout events.
    func start() {
        guard authListener == nil else { return }

        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, _ in
            Task { @MainActor [weak self] in
                self?.userID = Auth.auth().currentUser?.uid
                self?.userEmail = Auth.auth().currentUser?.email
                self?.isCheckingAuth = false
            }
        }
    }

    func signUp(email: String, password: String) async {
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            let result = try await Auth.auth().createUser(
                withEmail: email,
                password: password
            )
            userID = result.user.uid
            userEmail = result.user.email
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signIn(email: String, password: String) async {
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            let result = try await Auth.auth().signIn(
                withEmail: email,
                password: password
            )
            userID = result.user.uid
            userEmail = result.user.email
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        errorMessage = nil
        do {
            try Auth.auth().signOut()
            userID = nil
            userEmail = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

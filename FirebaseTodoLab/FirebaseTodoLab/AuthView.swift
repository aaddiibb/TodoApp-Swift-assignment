
import SwiftUI

struct AuthView: View {
    @ObservedObject var session: SessionStore

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isCreatingAccount = false
    @State private var validationError: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Email address", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    SecureField("Password", text: $password)
                        .textContentType(isCreatingAccount ? .newPassword : .password)

                    if isCreatingAccount {
                        SecureField("Confirm password", text: $confirmPassword)
                            .textContentType(.newPassword)
                    }
                } header: {
                    Text("Account")
                } footer: {
                    if isCreatingAccount {
                        Text("Use at least 6 characters for the password.")
                    }
                }

                if let message = validationError ?? session.errorMessage {
                    Section {
                        Text(message)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        submit()
                    } label: {
                        HStack {
                            Spacer()
                            if session.isBusy {
                                ProgressView()
                            } else {
                                Text(isCreatingAccount ? "Create Account" : "Sign In")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(session.isBusy)

                    Button(isCreatingAccount
                           ? "Already have an account? Sign In"
                           : "New user? Create an account") {
                        isCreatingAccount.toggle()
                        password = ""
                        confirmPassword = ""
                        validationError = nil
                        session.errorMessage = nil
                    }
                }
            }
            .navigationTitle(isCreatingAccount ? "Register" : "Todo Login")
        }
    }

    private func submit() {
        validationError = nil
        session.errorMessage = nil

        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanEmail.isEmpty else {
            validationError = "Please enter an email address."
            return
        }
        guard password.count >= 6 else {
            validationError = "Password must be at least 6 characters."
            return
        }
        if isCreatingAccount && password != confirmPassword {
            validationError = "Passwords do not match."
            return
        }

        Task {
            if isCreatingAccount {
                await session.signUp(email: cleanEmail, password: password)
            } else {
                await session.signIn(email: cleanEmail, password: password)
            }
        }
    }
}

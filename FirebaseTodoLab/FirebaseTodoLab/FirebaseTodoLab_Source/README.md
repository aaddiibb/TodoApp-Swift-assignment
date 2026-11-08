# FirebaseTodoLab (SwiftUI + Firebase)

Mobile Computing Lab project implementing email/password authentication and a per-user todo list with full CRUD operations in Cloud Firestore.

## Requirements

- macOS + a compatible Xcode installation; iOS 17+ deployment target
- Firebase project with an iOS app registered using the Xcode bundle identifier
- FirebaseAuth and FirebaseFirestore packages from https://github.com/firebase/firebase-ios-sdk.git
- Email/Password enabled in Firebase Authentication
- Cloud Firestore database with `firestore.rules` published in the Firebase Console

## Running

1. In Xcode, create **iOS > App** named `FirebaseTodoLab` with SwiftUI, Swift, and iOS 17+.
2. Make sure your Xcode target Bundle Identifier matches the registered Firebase iOS app.
3. Add FirebaseAuth and FirebaseFirestore via **File > Add Package Dependencies**.
4. Download `GoogleService-Info.plist` from Firebase Console and add it to the app target (the plist is intentionally excluded from Git).
5. Add the eight `.swift` files in this archive to your app target. Replace the generated app entry file and ContentView file; do not keep duplicate `@main` structs.
6. Set `FirebaseAppDelegateProxyEnabled` to Boolean `NO` in target Info settings.
7. Build and run in an iOS simulator or on a supported iPhone.

## Data structure

`users/{uid}/tasks/{taskId}`

Task fields: `title` (String), `description` (String), `isCompleted` (Bool), `createdAt` (Timestamp).

## Features

- Register and login using Firebase email/password authentication.
- Real-time list of tasks for the signed-in user.
- Create, read, edit, delete and mark tasks complete/incomplete.
- Logout and sign back in with persisted cloud tasks.
- Firestore security rules to isolate each user's data.

## Testing checklist

- [ ] Register a new account.
- [ ] Log in using that account.
- [ ] Create a task with title and description.
- [ ] Verify the task in Firestore Console.
- [ ] Edit the task and verify the update.
- [ ] Mark the task complete, then incomplete.
- [ ] Delete the task and verify its removal.
- [ ] Log out and log in; confirm cloud tasks persist.
- [ ] Create a second account; confirm it cannot see the first user's tasks.

## Security notes

Do not use permissive Firestore rules (`allow read, write: if true`). Firebase project client config is not a service-account secret, but this example intentionally excludes it from Git. Do not put service-account JSON, admin SDK credentials, or private signing keys in a repository.

## Important

This download contains app source files, **not** a prebuilt `.xcodeproj`. The Xcode app project must be created in Xcode and these files added to it. A complete local build requires the actual Firebase plist, Swift packages and Apple platform SDKs.

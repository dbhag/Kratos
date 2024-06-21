//
//  LoginView.swift
//  Kratos
//
//  Created by Dhruv Bhagavatula on 6/19/24.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore

enum AuthState {
    case signedIn
    case signedOut
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var errorMessage: ErrorMessage?
    @Published var state: AuthState = .signedOut
    @Published var signInMethod: String?
    private let db = Firestore.firestore()

    func signInWithGoogle() async {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            do {
                let result = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
                print("Restoring previous session")
                await authenticateGoogleUser(for: result)
            }
            catch {
                print(error.localizedDescription)
                self.errorMessage = ErrorMessage(message: error.localizedDescription)
            }
        } else {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

            do {
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
                await authenticateGoogleUser(for: result.user)
            }
            catch {
                print(error.localizedDescription)
                self.errorMessage = ErrorMessage(message: error.localizedDescription)
            }
        }
    }

    func authenticateGoogleUser(for user: GIDGoogleUser?) async {
        guard let idToken = user?.idToken?.tokenString else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user?.accessToken.tokenString ?? "")

        do {
            let authResult = try await Auth.auth().signIn(with: credential)
            self.state = .signedIn
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            self.signInMethod = "Google"
            storeUserData(authResult.user)
        }
        catch {
            print(error.localizedDescription)
            self.errorMessage = ErrorMessage(message: error.localizedDescription)
        }
    }
    private func storeUserData(_ user: FirebaseAuth.User) {
            let userRef = db.collection("users").document(user.uid)

            userRef.setData([
                "uid": user.uid,
                "email": user.email ?? "",
                "username": user.displayName ?? "Anonymous"
            ]) { error in
                if let error = error {
                    print("Error storing user data: \(error.localizedDescription)")
                }
            }
        }
}

struct ErrorMessage: Identifiable {
    var id = UUID()
    var message: String
}


struct LoginView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.16, green: 0.18, blue: 0.2)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer().frame(height: 100)
                    
                    // Title
                    Text("Login with Google")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 40)
                    
                    Spacer()
                    // Google Sign-In Button
                    Button(action: {
                        Task {
                            await authViewModel.signInWithGoogle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.white)
                            Text("Sign in with Google")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15.0)
                        .shadow(color: .gray, radius: 5, x: 0, y: 5)
                    }
                    .alert(item: $authViewModel.errorMessage) { error in
                        Alert(title: Text("Sign In Failed"), message: Text(error.message), dismissButton: .default(Text("OK")))
                    }
                    .background(
                        NavigationLink(destination: ContentView(), isActive: .constant(authViewModel.state == .signedIn)) {
                            EmptyView()
                        }
                    )
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    LoginView()
}

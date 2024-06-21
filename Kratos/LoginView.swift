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
    case needsUsername
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var errorMessage: ErrorMessage?
    @Published var state: AuthState = .signedOut
    @Published var signInMethod: String?
    private let db = Firestore.firestore()
    private var currentUser: FirebaseAuth.User?
    
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
            self.currentUser = authResult.user
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            self.signInMethod = "Google"
            checkIfUserExists(authResult.user)
        }
        catch {
            print(error.localizedDescription)
            self.errorMessage = ErrorMessage(message: error.localizedDescription)
        }
    }
    private func checkIfUserExists(_ user: FirebaseAuth.User) {
            let userRef = db.collection("users").document(user.uid)
            userRef.getDocument { document, error in
                if let document = document, document.exists {
                    self.state = .signedIn
                } else {
                    self.state = .needsUsername
                }
            }
        }
    func saveUsername(_ username: String) {
            guard let user = currentUser else { return }
            let userRef = db.collection("users").document(user.uid)
            
            userRef.setData([
                "uid": user.uid,
                "email": user.email ?? "",
                "username": username
            ]) { error in
                if let error = error {
                    print("Error storing user data: \(error.localizedDescription)")
                } else {
                    self.state = .signedIn
                }
            }
        }
}

struct ErrorMessage: Identifiable {
    var id = UUID()
    var message: String
}


struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

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
                    .background(
                      NavigationLink(destination: CreateUsernameView().environmentObject(authViewModel), isActive: .constant(authViewModel.state == .needsUsername)) {
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
struct CreateUsernameView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var username: String = ""

    var body: some View {
        VStack {
            Text("Create a Username")
                .font(.largeTitle)
                .padding()

            TextField("Username", text: $username)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)

            Button(action: {
                authViewModel.saveUsername(username)
            }) {
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(color: .gray, radius: 5, x: 0, y: 5)
            }
            .padding()
        }
        .padding()
    }
}
#Preview {
    LoginView()
}

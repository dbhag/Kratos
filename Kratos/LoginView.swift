//
//  LoginView.swift
//  Kratos
//
//  Created by Dhruv Bhagavatula on 6/19/24.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
       @State private var email: String = ""
       @State private var password: String = ""
       @State private var showAlert: Bool = false
       @State private var navigateToHome = false
       @State private var alertMessage: String = ""

       var body: some View {
           NavigationView {
               VStack {
                   Spacer()

                   // Title
                   Text("Login")
                       .font(.largeTitle)
                       .fontWeight(.bold)
                       .foregroundColor(.white)
                       .padding(.bottom, 40)

                   // Email Field
                   TextField("Email", text: $email)
                       .padding()
                       .background(Color.gray.opacity(0.2))
                       .cornerRadius(10)
                       .padding(.bottom, 20)
                       .keyboardType(.emailAddress)
                       .autocapitalization(.none)
                       .foregroundColor(.white)

                   // Password Field
                   SecureField("Password", text: $password)
                       .padding()
                       .background(Color.gray.opacity(0.2))
                       .cornerRadius(10)
                       .padding(.bottom, 20)
                       .foregroundColor(.white)

                   // Login Button
                   Button(action: {
                       login()
                   }) {
                       Text("Login")
                           .font(.headline)
                           .foregroundColor(Color(red: 0.16, green: 0.18, blue: 0.2))
                           .padding()
                           .frame(width: 220, height: 60)
                           .background(Color.white)
                           .cornerRadius(15.0)
                           .shadow(color: .gray, radius: 5, x: 0, y: 5)
                   }
                   .alert(isPresented: $showAlert) {
                       Alert(title: Text("Login Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                   }
                   .background(
                       NavigationLink(destination: ContentView(), isActive: $navigateToHome) {
                           EmptyView()
                       }
                   )

                   Spacer()
               }
               .padding()
               .background(Color(red: 0.16, green: 0.18, blue: 0.2))
               .edgesIgnoringSafeArea(.all)
               .navigationBarBackButtonHidden(true)
               .toolbar {
                   ToolbarItem(placement: .navigationBarLeading) {
                       Button("Back") {
                           presentationMode.wrappedValue.dismiss()
                       }
                   }
               }
           }
           .navigationBarBackButtonHidden(true)
       }

    func login() {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    // Handle the error by showing an alert
                    alertMessage = error.localizedDescription
                    showAlert = true
                } else {
                    // Navigate to home on successful login
                    navigateToHome = true
                }
            }
        }
    }
#Preview {
    LoginView()
}

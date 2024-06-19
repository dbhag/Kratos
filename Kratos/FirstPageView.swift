//
//  FirstPageView.swift
//  Kratos
//
//  Created by Dhruv Bhagavatula on 6/19/24.
//

import SwiftUI

struct FirstPageView: View {
    @State private var showLogin = false
        @State private var showSignUp = false

        var body: some View {
            NavigationView {
                ZStack {
                    Color(red: 0.16, green: 0.18, blue: 0.2)
                        .edgesIgnoringSafeArea(.all)

                    VStack {
                        Spacer()

                        // Title
                        Text("Welcome")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.bottom, 40)

                        // Subtitle
                        Text("Please sign in or create an account to continue.")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 60)

                        // Login Button
                        Button(action: {
                            showLogin.toggle()
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
                        .padding(.bottom, 20)
                        .fullScreenCover(isPresented: $showLogin) {
                            LoginView()
                        }

                        // Sign-Up Button
                        Button(action: {
                            showSignUp.toggle()
                        }) {
                            Text("Sign Up")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 220, height: 60)
                                .background(Color.blue)
                                .cornerRadius(15.0)
                                .shadow(color: .gray, radius: 5, x: 0, y: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15.0)
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                        }
                        .padding(.bottom, 40)
                        .fullScreenCover(isPresented: $showSignUp) {
                            CreateAccountView()
                        }

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
}

#Preview {
    FirstPageView()
}

//
//  AddFriendsView.swift
//  Kratos
//
//  Created by Dhruv Bhagavatula on 6/20/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct User: Identifiable {
    let id: String
    let username: String
    let email: String
}

struct AddFriendsView: View 
{
        @State private var searchQuery: String = ""
        @State private var searchResults: [User] = []
        @State private var friends: [User] = []
        private let db = Firestore.firestore()

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    Color(red: 0.16, green: 0.18, blue: 0.2)
                        .edgesIgnoringSafeArea(.all)
                    RadialGradient(gradient: Gradient(colors: [
                        Color.white.opacity(0.5),
                        Color.white.opacity(0.0)
                    ]), center: .center, startRadius: 50, endRadius: 300)
                    .blendMode(.overlay)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        // Header with Text and Flame Image
                        HStack(spacing: geometry.size.width * 0.05) {
                            Text("Add Friends")
                                .font(.custom("AmericanTypewriter", size: geometry.size.width * 0.075))
                                .tracking(0.36)
                                .minimumScaleFactor(0.8)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .offset(x: 0, y: -geometry.size.height * 0.05)
                        }
                        .padding(.horizontal, geometry.size.width * 0.08)
                        .frame(height: geometry.size.height * 0.1)
                        .padding(.top, geometry.size.height * 0.05)

                        // Search by Username or Email Section
                        HStack {
                            TextField("Search by username or email", text: $searchQuery, onCommit: searchUser)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .padding(.horizontal)

                            Button(action: searchUser) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                        List(searchResults) { user in
                            HStack {
                                Text(user.username)
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: {
                                      addFriend(user: user)
                                }) {
                                    Text("Add")
                                        .foregroundColor(.blue)
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                        .background(Color.clear)
                        .scrollContentBackground(.hidden)

                        Spacer()

                        Text("Friends:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()

                        List(friends) { friend in
                           Text(friend.username)
                                   .foregroundColor(.white)
                                   .listRowBackground(Color.clear)
                        }
                        .background(Color.clear)
                        .scrollContentBackground(.hidden)
                        Spacer()
                  }
              }
          }
       .navigationTitle("Add Friends")
  }

        private func searchUser() {
            guard !searchQuery.isEmpty else {
                searchResults = []
                return
            }

            db.collection("users")
                .whereField("username", isEqualTo: searchQuery)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error searching users: \(error.localizedDescription)")
                        return
                    }
                    guard let documents = snapshot?.documents else { return }
                    self.searchResults = documents.map { doc in
                        let data = doc.data()
                        return User(id: doc.documentID, username: data["username"] as? String ?? "", email: data["email"] as? String ?? "")
                    }
                }

            db.collection("users")
                .whereField("email", isEqualTo: searchQuery)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error searching users: \(error.localizedDescription)")
                        return
                    }
                    guard let documents = snapshot?.documents else { return }
                    self.searchResults += documents.map { doc in
                        let data = doc.data()
                        return User(id: doc.documentID, username: data["username"] as? String ?? "", email: data["email"] as? String ?? "")
                    }
                }
        }

        private func addFriend(user: User) {
            guard let currentUserID = Auth.auth().currentUser?.uid else { return }

            let friendRequest = [
                "from": currentUserID,
                "to": user.id,
                "status": "pending"
            ] as [String : Any]

            db.collection("friendRequests").addDocument(data: friendRequest) { error in
                if let error = error {
                    print("Error adding friend: \(error.localizedDescription)")
                    return
                }
                print("Friend request sent to \(user.username)")
            }
        }
}

#Preview {
    AddFriendsView()
}

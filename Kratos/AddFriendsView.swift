import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct User: Identifiable {
    let id: String
    let username: String
    let email: String
}

struct AddFriendsView: View {
    @State private var searchQuery: String = ""
    @State private var searchResults: [User] = []
    @State private var incomingRequests: [User] = []
    @State private var showOverlay: Bool = false
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

                    // Search by Username Section
                    HStack {
                        TextField("Search by username", text: $searchQuery)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .onChange(of: searchQuery) { newValue in
                                searchUser()
                            }

                        Button(action: searchUser) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                    // Incoming Friend Requests
                    Text("Incoming Friend Requests")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top)

                    List(incomingRequests) { user in
                        HStack {
                            Text(user.username)
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: {
                                acceptFriendRequest(from: user)
                            }) {
                                Text("Accept")
                                    .foregroundColor(.green)
                            }
                            Button(action: {
                                rejectFriendRequest(from: user)
                            }) {
                                Text("Reject")
                                    .foregroundColor(.red)
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)

                    Spacer()
                }

                if showOverlay {
                    overlayView
                        .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.5)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.horizontal, geometry.size.width * 0.05)
                        .offset(y: geometry.size.height * 0.15)
                }
            }
        }
        .navigationTitle("Add Friends")
        .onAppear {
            fetchIncomingRequests()
        }
    }

    private var overlayView: some View {
        VStack {
            Text("Search Results")
                .font(.headline)
                .foregroundColor(.white)
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
        }
        .padding()
    }

    private func searchUser() {
        guard !searchQuery.isEmpty else {
            searchResults = []
            showOverlay = false
            return
        }

        db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: searchQuery)
            .whereField("username", isLessThanOrEqualTo: searchQuery + "\u{f8ff}")
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
                self.showOverlay = !self.searchResults.isEmpty
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

    private func fetchIncomingRequests() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("friendRequests")
            .whereField("to", isEqualTo: currentUserID)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching incoming requests: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                let fromIDs = documents.map { $0.data()["from"] as! String }
                
                self.db.collection("users").whereField("uid", in: fromIDs).getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching user data: \(error.localizedDescription)")
                        return
                    }
                    guard let documents = snapshot?.documents else { return }
                    self.incomingRequests = documents.map { doc in
                        let data = doc.data()
                        return User(id: doc.documentID, username: data["username"] as? String ?? "", email: data["email"] as? String ?? "")
                    }
                }
            }
    }

    private func acceptFriendRequest(from user: User) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        db.collection("friendRequests")
            .whereField("from", isEqualTo: user.id)
            .whereField("to", isEqualTo: currentUserID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error accepting friend request: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                for document in documents {
                    document.reference.updateData(["status": "accepted"]) { error in
                        if let error = error {
                            print("Error updating friend request status: \(error.localizedDescription)")
                            return
                        }
                        print("Friend request from \(user.username) accepted")
                        fetchIncomingRequests()
                    }
                }
            }
    }

    private func rejectFriendRequest(from user: User) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        db.collection("friendRequests")
            .whereField("from", isEqualTo: user.id)
            .whereField("to", isEqualTo: currentUserID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error rejecting friend request: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                for document in documents {
                    document.reference.delete() { error in
                        if let error = error {
                            print("Error deleting friend request: \(error.localizedDescription)")
                            return
                        }
                        print("Friend request from \(user.username) rejected")
                        fetchIncomingRequests()
                    }
                }
            }
    }
}

#Preview {
    AddFriendsView()
}


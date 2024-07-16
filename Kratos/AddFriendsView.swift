import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct User: Identifiable {
    let id: String
    let username: String
    let email: String
    var recentWorkout: Timestamp?
    
    init(id: String, username: String, email: String, recentWorkout: Timestamp? = nil) {
            self.id = id
            self.username = username
            self.email = email
            self.recentWorkout = recentWorkout
    }
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
                            .font(.custom("Marker Felt", size: geometry.size.width * 0.075))
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
                            .onChange(of: searchQuery) { 
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
                    .padding(.top, -geometry.size.height * 0.05)
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
                                    .foregroundColor(.white)
                                    .font(.custom("Marker Felt", size: geometry.size.width * 0.055))
                                    .frame(width: geometry.size.width * 0.12, height:  geometry.size.height * 0.05)
                                    .background(Color.green) // Background color for the rectangle
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 5)
                            }
                            Button(action: {
                                rejectFriendRequest(from: user)
                            }) {
                                Text("Reject")
                                    .foregroundColor(.white)
                                    .font(.custom("Marker Felt", size: geometry.size.width * 0.055))
                                    .frame(width: geometry.size.width * 0.12, height:  geometry.size.height * 0.05)
                                    .background(Color.red) // Background color for the rectangle
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 5)
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
                        .background(Color.gray.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.horizontal, geometry.size.width * 0.05)
                        .offset(y: geometry.size.height * 0)
                }
            }
        }
        .onAppear {
            fetchIncomingRequests()
        }
    }

    private var overlayView: some View {
        VStack {
            GeometryReader { geometry in
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
                                .foregroundColor(.white)
                                .font(.custom("Marker Felt", size: geometry.size.width * 0.055))
                                .frame(width: geometry.size.width * 0.12, height:  geometry.size.height * 0.05)
                                .background(Color.blue) // Background color for the rectangle
                                .cornerRadius(5)
                                .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 5)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .listRowBackground(Color.clear)
                }
                .background(Color.clear)
                .scrollContentBackground(.hidden)
            }
            .padding()
            .background(Color.black.opacity(0.8)) // Ensure background to avoid interaction issues
            .cornerRadius(10)
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure the overlay takes the full space
            .onTapGesture {
                // Dismiss overlay when tapped outside
                self.showOverlay = false
            }
        }
    }

    private func searchUser() {
        guard !searchQuery.isEmpty else {
            searchResults = []
            showOverlay = false
            return
        }

        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let userRef = db.collection("users").document(currentUserID)

        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }

            guard let document = document else { return }

            let friendsCollection = db.collection("friends").document(currentUserID).collection("friendsList")

            friendsCollection.getDocuments { friendsSnapshot, error in
                if let error = error {
                    print("Error fetching friends list: \(error.localizedDescription)")
                    return
                }

                let friends = friendsSnapshot?.documents.compactMap { $0.documentID } ?? []

                self.db.collection("users")
                    .whereField("username", isGreaterThanOrEqualTo: self.searchQuery)
                    .whereField("username", isLessThanOrEqualTo: self.searchQuery + "\u{f8ff}")
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("Error searching users: \(error.localizedDescription)")
                            return
                        }
                        guard let documents = snapshot?.documents else { return }

                        self.searchResults = documents.compactMap { doc in
                            let data = doc.data()
                            let userId = doc.documentID
                            let username = data["username"] as? String ?? ""
                            let email = data["email"] as? String ?? ""

                            // Exclude the current user and their friends
                            if userId != currentUserID && !friends.contains(userId) {
                                return User(id: userId, username: username, email: email)
                            }
                            return nil
                        }

                        self.showOverlay = !self.searchResults.isEmpty
                    }
            }
        }
    }

    private func addFriend(user: User) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        // Check to ensure the user is not sending a friend request to themselves
        guard currentUserID != user.id else {
            print("Cannot send friend request to yourself.")
            return
        }

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
                
                guard !fromIDs.isEmpty else
                {
                   self.incomingRequests = []
                   return
                }
                
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

        print("Accepting friend request. Current User ID: \(currentUserID), Friend User ID: \(user.id)")

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
                        self.addFriendsToEachOther(currentUserID: currentUserID, friendUser: user)
                    }
                }
            }
    }

    private func addFriendsToEachOther(currentUserID: String, friendUser: User) {
        let friendsCollection = db.collection("friends")
        let batch = db.batch()

        // Fetch the current user's username
        db.collection("users").document(currentUserID).getDocument { (document, error) in
            if let document = document, document.exists {
                let currentUsername = document.data()?["username"] as? String ?? ""

                // Add the friend to the current user's friends list
                let currentUserFriendRef = friendsCollection.document(currentUserID).collection("friendsList").document(friendUser.id)
                batch.setData(["uid": friendUser.id, "username": friendUser.username], forDocument: currentUserFriendRef)

                // Add the current user to the friend's friends list
                let userFriendRef = friendsCollection.document(friendUser.id).collection("friendsList").document(currentUserID)
                batch.setData(["uid": currentUserID, "username": currentUsername], forDocument: userFriendRef)

                batch.commit { error in
                    if let error = error {
                        print("Error adding friend to friends collection: \(error.localizedDescription)")
                        return
                    }
                    print("Both users have been added to each other's friends list")
                    self.fetchIncomingRequests()
                }
            } else {
                print("Current user document does not exist")
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


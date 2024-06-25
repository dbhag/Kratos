import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

class FirestoreService: ObservableObject {
    @Published var leaderboardEntries: [LeaderboardEntry] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    func fetchFriendsLeaderboardEntries() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        // Fetch the current user's data
        db.collection("users").document(currentUserID).getDocument { (document, error) in
            if let document = document, document.exists {
                let currentUserData = document.data()
                let currentUserEntry = LeaderboardEntry(
                    id: document.documentID,
                    name: currentUserData?["username"] as? String ?? "",
                    score: currentUserData?["score"] as? Int ?? 0
                )

                // Fetch friends data
                self.db.collection("friends")
                    .document(currentUserID)
                    .collection("friendsList")
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("Error fetching friends: \(error)")
                            return
                        }

                        let friendIDs = snapshot?.documents.compactMap { $0.documentID } ?? []

                        guard !friendIDs.isEmpty else {
                            self.leaderboardEntries = [currentUserEntry]
                            return
                        }

                        self.fetchFriendsData(friendIDs: friendIDs, currentUserEntry: currentUserEntry)
                    }
            } else {
                print("Current user document does not exist")
            }
        }
    }

    private func fetchFriendsData(friendIDs: [String], currentUserEntry: LeaderboardEntry) {
        guard !friendIDs.isEmpty else {
            self.leaderboardEntries = [currentUserEntry]
            return
        }

        db.collection("users")
            .whereField("uid", in: friendIDs)
            .getDocuments(source: .default) { snapshot, error in
                if let error = error {
                    print("Error fetching friend data: \(error)")
                    return
                }

                let friendsEntries = snapshot?.documents.compactMap { document -> LeaderboardEntry? in
                    let data = document.data()
                    guard let name = data["username"] as? String,
                          let score = data["score"] as? Int else { return nil }
                    return LeaderboardEntry(id: document.documentID, name: name, score: score)
                } ?? []
                self.leaderboardEntries = friendsEntries.sorted(by: { $0.score > $1.score })
            }
    }

    func addEntry(_ entry: LeaderboardEntry) {
        db.collection("leaderboard").addDocument(data: [
            "name": entry.name,
            "score": entry.score
        ])
    }

    func initializeUserScoreIfNeeded() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let userRef = db.collection("users").document(currentUserID)
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                if document.data()?["score"] == nil {
                    userRef.updateData(["score": 0])
                }
            } else {
                userRef.setData([
                    "username": Auth.auth().currentUser?.displayName ?? "Unknown",
                    "score": 0
                ])
            }
        }
    }
}

struct LeaderboardEntry: Identifiable {
    var id: String
    var name: String
    var score: Int
}


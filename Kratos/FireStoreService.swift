import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

class FirestoreService: ObservableObject {
    @Published var leaderboardEntries: [LeaderboardEntry] = []
    @Published var recentWorkouts: [RecentWorkout] = []
    @Published var previousWorkouts: [Workout] = []
    @Published var longestStreak: Int = 0
    @Published var totalWorkouts: Int = 0
    @Published var userScore: Int = 0
        
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    func fetchFriendsLeaderboardEntries() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(currentUserID).getDocument { (document, error) in
            if let document = document, document.exists {
                let currentUserData = document.data()
                let currentUserEntry = LeaderboardEntry(
                    id: document.documentID,
                    name: currentUserData?["username"] as? String ?? "",
                    score: currentUserData?["score"] as? Int ?? 0
                )

                self.db.collection("friends")
                    .document(currentUserID)
                    .collection("friendsList")
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("Error fetching friends: \(error)")
                            return
                        }

                        let friendIDs = snapshot?.documents.compactMap { $0.documentID } ?? []
                        print("Fetched friend: \(friendIDs)")
                        guard !friendIDs.isEmpty else {
                            print("got here")
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
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching friend data: \(error)")
                    return
                }

                var friendsEntries = snapshot?.documents.compactMap { document -> LeaderboardEntry? in
                    let data = document.data()
                    guard let name = data["username"] as? String,
                          let score = data["score"] as? Int else { return nil }
                    return LeaderboardEntry(id: document.documentID, name: name, score: score)
                } ?? []
                print("Fetched friendEntries: \(friendsEntries)")
                friendsEntries.append(currentUserEntry)
                self.leaderboardEntries = friendsEntries.sorted(by: { $0.score > $1.score })
                print("Fetched leaderboard: \(self.leaderboardEntries)")
            }
    }

    func fetchFriendsRecentWorkouts() {
            guard let currentUserID = Auth.auth().currentUser?.uid else { return }

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
                        self.recentWorkouts = []
                        return
                    }

                    self.fetchRecentWorkoutsData(friendIDs: friendIDs)
                }
        }

        private func fetchRecentWorkoutsData(friendIDs: [String]) {
            guard !friendIDs.isEmpty else {
                self.recentWorkouts = []
                return
            }

            db.collection("users")
                .whereField("uid", in: friendIDs)
                .getDocuments(source: .default) { snapshot, error in
                    if let error = error {
                        print("Error fetching friend data: \(error)")
                        return
                    }

                    let friendWorkouts = snapshot?.documents.compactMap { document -> RecentWorkout? in
                        let data = document.data()
                        guard let username = data["username"] as? String,
                              let recentWorkout = data["recentWorkout"] as? Timestamp else { return nil }
                        return RecentWorkout(id: document.documentID, username: username, recentWorkout: recentWorkout.dateValue())
                    } ?? []
                    self.recentWorkouts = friendWorkouts.sorted(by: { $0.recentWorkout > $1.recentWorkout })
                    print("Fetched workouts: \(self.recentWorkouts)")
                }
        }
    func fetchPreviousWorkouts() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(currentUserID).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let workoutEntries = data?["workouts"] as? [[String: Any]] ?? []

                self.previousWorkouts = workoutEntries.compactMap { entry in
                    guard let exercises = entry["workouts"] as? [String],
                          let timestamp = entry["timestamp"] as? Timestamp,
                          let description = entry["description"] as? String else {
                            return nil
                    }
                    return Workout(id: UUID().uuidString, exercises: exercises, timestamp: timestamp.dateValue(), description: description)
                }.sorted(by: { $0.timestamp > $1.timestamp })

                print("Fetched workouts: \(self.previousWorkouts)")  // Debug print
            } else {
                print("Document does not exist or error: \(String(describing: error))")  // Debug print
            }
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
    func fetchUserStats() {
            guard let currentUserID = Auth.auth().currentUser?.uid else { return }

            db.collection("users").document(currentUserID).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    self.longestStreak = data?["longestStreak"] as? Int ?? 0
                    self.totalWorkouts = data?["totalWorkouts"] as? Int ?? 0
                } else {
                    print("Document does not exist or error: \(String(describing: error))")
                }
            }
        }
    func fetchUserScore() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(currentUserID).getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                self.userScore = data["score"] as? Int ?? 0
            } else {
                print("Error fetching user score: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
}

struct LeaderboardEntry: Identifiable {
    var id: String
    var name: String
    var score: Int
}

struct RecentWorkout: Identifiable {
    var id: String
    var username: String
    var recentWorkout: Date
}

struct Workout: Identifiable {
    var id:  String
    var exercises: [String]
    var timestamp: Date
    var description: String
}


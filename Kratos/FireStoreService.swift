// FirestoreService.swift
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreService: ObservableObject {
    private var db = Firestore.firestore()
    @Published var leaderboardEntries = [LeaderboardEntry]()

    init() {
        fetchLeaderboard()
    }

    func fetchLeaderboard() {
        db.collection("leaderboard").order(by: "score", descending: true).addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                self.leaderboardEntries = querySnapshot.documents.compactMap { document in
                    try? document.data(as: LeaderboardEntry.self)
                }
            }
        }
    }

    func addEntry(_ entry: LeaderboardEntry) {
        do {
            _ = try db.collection("leaderboard").addDocument(from: entry)
        } catch {
            print("Error adding document: \(error)")
        }
    }
}


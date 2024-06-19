import SwiftUI
import FirebaseFirestoreSwift

struct LeaderboardEntry: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let score: Int
}

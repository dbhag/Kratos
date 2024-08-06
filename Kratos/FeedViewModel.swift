//
//  FeedViewModel.swift
//  Kratos
//
//  Created by Dhruv Bhagavatula on 7/18/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift
import FirebaseAuth

class FeedViewModel: ObservableObject {
    @Published var posts = [Post]()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    @Published var userPosts = [Post]() //= []
    
    func uploadPost(image: UIImage, caption: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        let imageName = UUID().uuidString
        let imageRef = storage.reference().child("images/\(imageName).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error)")
                return
            }
            
            imageRef.downloadURL { url, error in
                if let url = url {
                    self.db.collection("users").document(currentUserID).getDocument { document, error in
                        if let document = document, let data = document.data() {
                            let username = data["username"] as? String ?? "Unknown"
                            let newPost = [
                                "userId": currentUserID,
                                "username": username,
                                "timestamp": FieldValue.serverTimestamp(),
                                "photoURL": url.absoluteString,
                                "caption": caption,
                            ] as [String : Any]
                            
                            self.db.collection("posts").addDocument(data: newPost)
                        }
                    }
                }
            }
        }
    }
    func fetchFriendsPosts() {
            guard let currentUserID = Auth.auth().currentUser?.uid else { return }

            // Fetch friends list
            let friendsRef = db.collection("friends").document(currentUserID).collection("friendsList")
            friendsRef.getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching friends: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }

                // Fetch most recent post for each friend
                let group = DispatchGroup()
                var fetchedPosts = [Post]()

                for document in documents {
                    let friendID = document.documentID
                    group.enter()
                    self?.fetchMostRecentPost(for: friendID) { post in
                        if let post = post {
                            fetchedPosts.append(post)
                        }
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    self?.posts = fetchedPosts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
                }
            }
        }

        private func fetchMostRecentPost(for userID: String, completion: @escaping (Post?) -> Void) {
            let postsRef = db.collection("posts").whereField("userId", isEqualTo: userID).order(by: "timestamp", descending: true).limit(to: 1)
            postsRef.getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching post: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                guard let document = snapshot?.documents.first else {
                    completion(nil)
                    return
                }
                do {
                    let post = try document.data(as: Post.self)
                    completion(post)
                } catch {
                    print("Error decoding post: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }
    func fetchUserPosts() 
    {
            guard let currentUserID = Auth.auth().currentUser?.uid else { return }

            // Fetch posts by the current user
            db.collection("posts")
                .whereField("userId", isEqualTo: currentUserID)
                .order(by: "timestamp", descending: true)
                .getDocuments { [weak self] snapshot, error in
                    if let error = error {
                        print("Error fetching user posts: \(error.localizedDescription)")
                        return
                    }
                    guard let documents = snapshot?.documents else { return }

                    self?.userPosts = documents.compactMap { document in
                        try? document.data(as: Post.self)
                    }
                }
    }
}

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var username: String
    var timestamp: Timestamp
    var photoURL: String
    var caption: String
}


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct FeedView: View {
    @ObservedObject var feedViewModel = FeedViewModel()

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color(red: 0.16, green: 0.18, blue: 0.2)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        // Header
                        HStack {
                            Text("Feed")
                                .font(.custom("Marker Felt", size: geometry.size.width * 0.075))
                                .foregroundColor(.white)
                                .padding(.leading, 20)
                            Spacer()
                        }
                        .padding(.top, 20)
                        
                        // Feed Content
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(feedViewModel.posts) { post in
                                    FeedPostView(post: post, geometry: geometry)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            feedViewModel.fetchFriendsPosts()
        }
    }
}

struct FeedPostView: View {
    var post: Post
    var geometry: GeometryProxy

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(post.username)
                .font(.custom("Marker Felt", size: geometry.size.width * 0.05))
                .foregroundColor(.white)
            if let url = URL(string: post.photoURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxHeight: 300)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            Text(post.caption)
                .font(.custom("Marker Felt", size: geometry.size.width * 0.04))
                .foregroundColor(.gray)
            Text(post.timestamp.dateValue(), style: .date)
                .font(.custom("Marker Felt", size: geometry.size.width * 0.04))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(red: 0.16, green: 0.18, blue: 0.2).opacity(0.8))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 5)
    }
}


#Preview {
    FeedView()
}

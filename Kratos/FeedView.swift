import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import SDWebImageSwiftUI

struct FeedView: View {
    @EnvironmentObject var feedViewModel: FeedViewModel

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color(red: 0.16, green: 0.18, blue: 0.2)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
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
            Text(post.caption)
                .font(.custom("Marker Felt", size: geometry.size.width * 0.04))
                .foregroundColor(.gray)
            
            if let url = URL(string: post.photoURL) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.16, green: 0.18, blue: 0.2))
                        .frame(maxHeight: geometry.size.height / 2)
                    
                    WebImage(url: url)
                        .onSuccess { image, data, cacheType in
                            // Success handler
                            print("Image loaded successfully!")
                        }
                        /*.placeholder {
                            ProgressView()
                                .frame(maxHeight: 300)
                        }*/
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: geometry.size.height / 2)
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                }
            }
        }
        .padding()
        .background(Color(red: 0.16, green: 0.18, blue: 0.2))
        .cornerRadius(10)
        //.shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 5)
    }
}


#Preview {
    FeedView()
}

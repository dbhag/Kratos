import SwiftUI
import SceneKit

struct ProfileView: View {
    @ObservedObject var firestoreService = FirestoreService()
    @ObservedObject var feedViewModel = FeedViewModel()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.16, green: 0.18, blue: 0.2)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Header with Text
                    HStack(spacing: geometry.size.width * 0.05) {
                        Text("My Profile")
                            .font(.custom("Marker Felt", size: geometry.size.width * 0.075))
                            .tracking(0.36)
                            .minimumScaleFactor(0.8)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .offset(x: 0, y: -geometry.size.height * 0.046)
                    }
                    .padding(.horizontal, geometry.size.width * 0.08)
                    .frame(height: geometry.size.height * 0.1)
                    .padding(.top, geometry.size.height * 0.05)

                    // 3D Model and Stats View
                    HStack {
                        if let modelName = getModelName(for: firestoreService.userScore) {
                            SceneView(
                                scene: {
                                    let scene = SCNScene(named: "art.scnassets/\(modelName)")!
                                    
                                    // Set the scene background color to match the app's theme
                                    scene.background.contents = UIColor(red: 0.16, green: 0.18, blue: 0.2, alpha: 1.0)
                                    
                                    // Add custom lighting
                                    let ambientLight = SCNLight()
                                    ambientLight.type = .ambient
                                    ambientLight.color = UIColor(white: 0.8, alpha: 1.0)
                                    
                                    let ambientLightNode = SCNNode()
                                    ambientLightNode.light = ambientLight
                                    scene.rootNode.addChildNode(ambientLightNode)
                                    
                                    return scene
                                }(),
                                options: [.autoenablesDefaultLighting, .allowsCameraControl]
                            )
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.2)
                            .background(Color.clear) // Ensure background is clear
                            .cornerRadius(20)
                            .padding(.top, -20)
                            .offset(x: -geometry.size.width * 0.03, y: geometry.size.height * 0.015)
                        }
                        
                        VStack(spacing: 20) {
                            // Longest Streak Box
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.white.opacity(0.09))
                                    .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.08)
                                
                                HStack {
                                    Text("Longest Streak:")
                                        .font(.custom("Marker Felt", size: geometry.size.width * 0.04))
                                        .foregroundColor(.white)
                                    Text("\(firestoreService.longestStreak) weeks")
                                        .font(.custom("Marker Felt", size: geometry.size.width * 0.04))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal)
                            }
                            
                            // Total Workouts Box
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.white.opacity(0.09))
                                    .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.08)
                                
                                HStack {
                                    Text("Total Workouts:")
                                        .font(.custom("Marker Felt", size: geometry.size.width * 0.04))
                                        .foregroundColor(.white)
                                    Text("\(firestoreService.totalWorkouts)")
                                        .font(.custom("Marker Felt", size: geometry.size.width * 0.04))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // User Posts
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(feedViewModel.userPosts) { post in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(post.caption)
                                        .font(.custom("Marker Felt", size: geometry.size.width * 0.05))
                                        .foregroundColor(.white)
                                    Text(post.timestamp.dateValue(), style: .date)
                                        .font(.custom("Marker Felt", size: geometry.size.width * 0.04))
                                        .foregroundColor(.gray)
                                    if let url = URL(string: post.photoURL) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(maxHeight: geometry.size.height/3)
                                            case .success(let image):
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color(red: 0.16, green: 0.18, blue: 0.2)) // Change this to match your background color
                                                        .frame(maxHeight: geometry.size.height/3)
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(maxHeight: geometry.size.height/3)
                                                        .cornerRadius(40)
                                                }
                                            case .failure:
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(maxHeight: geometry.size.height/3)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    }
                                    /*.frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.3)
                                    .background(Color(red: 0.16, green: 0.18, blue: 0.2))
                                    .cornerRadius(10)*/
                                }
                                .padding()
                                .background(Color(red: 0.16, green: 0.18, blue: 0.2)/*.opacity(0.8)*/)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            firestoreService.fetchUserStats()
            feedViewModel.fetchUserPosts()
        }
    }
    
    // Helper function to get model name based on score
    func getModelName(for score: Int) -> String? {
        switch score {
        case 0..<200:
            return "frog.usdz"
        case 200..<400:
            return "cat.usdz"
        case 400..<700:
            return "dog.usdz"
        case 700..<1000:
            return "deer.usdz"
        case 1000..<1500:
            return "bear.usdz"
        case 1500..<2000:
            return "bison.usdz"
        case 2000...:
            return "penguin.usdz"
        default:
            return nil
        }
    }
}

#Preview {
    ProfileView()
}


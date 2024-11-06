import SwiftUI
import SceneKit
import SDWebImageSwiftUI


struct ProfileView: View {
    //@ObservedObject var firestoreService = FirestoreService()
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var feedViewModel: FeedViewModel
    //@ObservedObject var feedViewModel = FeedViewModel()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.16, green: 0.18, blue: 0.2)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Header with Text
                    HStack(spacing: geometry.size.width * 0.05) {
                        Text("My Profile")
                            .font(.custom("Poppins-Regular", size: geometry.size.width * 0.075))
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
                                    let scene = loadOptimizedScene(named: modelName)!
                                    
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
                            .background(Color.clear) // Ensure background is clears
                            .cornerRadius(20)
                            .padding(.top, -20)
                            .offset(x: -geometry.size.width * 0.03, y: geometry.size.height * 0.015)
                        }
                        
                        VStack(spacing: 20) {
                            // Longest Streak Box
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.white.opacity(0.09))
                                    .frame(width: geometry.size.width * 0.55, height: geometry.size.height * 0.08)
                                
                                HStack {
                                    Text("Longest Streak:")
                                        .font(.custom("Poppins-Regular", size: geometry.size.width * 0.04))
                                        .foregroundColor(.white)
                                    Text("\(firestoreService.longestStreak) weeks")
                                        .font(.custom("Poppins-Regular", size: geometry.size.width * 0.04))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal)
                            }
                            
                            // Total Workouts Box
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.white.opacity(0.09))
                                    .frame(width: geometry.size.width * 0.55, height: geometry.size.height * 0.08)
                                
                                HStack {
                                    Text("Total Workouts:")
                                        .font(.custom("Poppins-Regular", size: geometry.size.width * 0.04))
                                        .foregroundColor(.white)
                                    Text("\(firestoreService.totalWorkouts)")
                                        .font(.custom("Poppins-Regular", size: geometry.size.width * 0.04))
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
                                        .font(.custom("Poppins-Regular", size: geometry.size.width * 0.05))
                                        .foregroundColor(.white)
                                    Text(post.timestamp.dateValue(), style: .date)
                                        .font(.custom("Poppins-Regular", size: geometry.size.width * 0.04))
                                        .foregroundColor(.gray)
                                    if let url = URL(string: post.photoURL) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 40)
                                                .fill(Color(red: 0.16, green: 0.18, blue: 0.2))
                                                .frame(maxHeight: geometry.size.height / 3)
                                            
                                            WebImage(url: url)
                                                .onSuccess { image, data, cacheType in
                                                    // Success handler
                                                    print("Image loaded successfully!")
                                                }
                                                /*.placeholder {
                                                    ProgressView()
                                                        .frame(maxHeight: geometry.size.height / 3)
                                                }*/
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(maxHeight: geometry.size.height / 3)
                                                .clipShape(RoundedRectangle(cornerRadius: 40))
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 20)
                    Spacer()
                    /*ScrollView {
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
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()*/
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
            return "rabbit.usdz"
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
    func isOlderDevice() -> Bool {
        let deviceIdentifier = UIDevice.current.modelIdentifier
        
        let olderDevices = [
            "iPhone12,1", "iPhone12,3", "iPhone12,5", // iPhone 11 series (A13)
            "iPhone11,2", "iPhone11,4", "iPhone11,6", "iPhone11,8", // iPhone XS, XR (A12)
            "iPhone10,3", "iPhone10,6", // iPhone X (A11)
            "iPhone10,1", "iPhone10,4", "iPhone10,2", "iPhone10,5" // iPhone 8, 8 Plus (A11)
        ]
        
        return olderDevices.contains(deviceIdentifier)
    }

    // Helper function to load an optimized scene based on the device
    func loadOptimizedScene(named modelName: String) -> SCNScene? {
        if isOlderDevice() {
            // Load a lower-resolution model for older devices
            let lowResModelName = modelName.replacingOccurrences(of: ".usdz", with: "_low.usdz") // Assuming low-res models are named _low
            return SCNScene(named: "art.scnassets/\(lowResModelName)") ?? SCNScene(named: "art.scnassets/\(modelName)")
        } else {
            // Load the full-resolution model for newer devices
            return SCNScene(named: "art.scnassets/\(modelName)")
        }
    }
}

#Preview {
    ProfileView()
}


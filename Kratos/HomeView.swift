import SwiftUI
import SceneKit

struct ContentView: View {
    @ObservedObject var firestoreService = FirestoreService()
    @Binding var selectedTab: Tab
    @Binding var showPlusButton: Bool

    var body: some View {
            GeometryReader { geometry in
                ZStack {
                    Color(red: 0.16, green: 0.18, blue: 0.2)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        // Header with Text and Flame Image
                        HStack(spacing: geometry.size.width * 0.05) {
                            Text("Kratos")
                                .font(.custom("Marker Felt", size: geometry.size.width * 0.075))
                                .tracking(0.36)
                                .minimumScaleFactor(0.8)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .offset(x: 0, y: -geometry.size.height * 0.0325)
                        }
                        .padding(.horizontal, geometry.size.width * 0.08)
                        .frame(height: geometry.size.height * 0.1)
                        .padding(.top, geometry.size.height * 0.05)
                       
                        Spacer()

                        
                        // 3D Model View
                        if let modelName = getModelName(for: firestoreService.userScore) {
                            //print("Loading model: \(modelName)")
                            SceneView(
                                scene: {
                                    guard let scene = SCNScene(named: "art.scnassets/\(modelName)") else {
                                                    print("Failed to load the scene with model name: \(modelName)")
                                                    return SCNScene() // Return an empty scene if loading fails
                                                }
                                    
                                    // Set the scene background color to match the app's theme
                                    scene.background.contents = UIColor(red: 0.16, green: 0.18, blue: 0.2, alpha: 1)
                                    
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
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.4)
                            .background(Color(red: 0.16, green: 0.18, blue: 0.2)) // Ensure background is clear
                            .cornerRadius(20)
                            //.padding(.top, -14)
                            //.padding(.top, -geometry.size.height * 0.02)
                            .offset(y: -geometry.size.height * 0.05)
                        }
                        
                        Spacer()


                        // Progress Snippet View
                        ZStack {
                            Button(action: {
                             selectedTab = .progress
                            }) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.1)
                                    //.background(Color.white.opacity(0.09))
                                    .cornerRadius(24)
                                    .shadow(color: Color.white.opacity(0.5), radius: 50, x: 5, y: 5)
                            }
                            HStack {
                                if let modelName = getModelName(for: firestoreService.userScore) {
                                    SceneView(
                                        scene: {
                                            let scene = SCNScene(named: "art.scnassets/\(modelName)")!
                                            scene.background.contents = UIColor(red: 0.16, green: 0.18, blue: 0.2, alpha: 1)
                                            return scene
                                        }(),
                                        options: [.autoenablesDefaultLighting, .allowsCameraControl]
                                    )
                                    .frame(width: geometry.size.width * 0.25, height: geometry.size.height * 0.1)
                                    .cornerRadius(20)
                                    //.padding(.leading, 50)
                                    .padding(.leading, geometry.size.width * 0.11)
                                    //.scaledToFit()
                                }
                                
                                let nextAnimal = getNextAnimal(for: firestoreService.userScore)
                                let pointsToNextAnimal = nextAnimal.points - firestoreService.userScore

                                VStack {
                                    Text("\(pointsToNextAnimal) points")
                                        .foregroundColor(.white)
                                        .font(.custom("Marker Felt", size: geometry.size.width * 0.04))
                                    
                                    GeometryReader { geo in
                                        Path { path in
                                            let width = geo.size.width
                                            let height = geo.size.height
                                            path.move(to: CGPoint(x: 0, y: height / 2))
                                            path.addLine(to: CGPoint(x: width, y: height / 2))
                                        }
                                        .stroke(Color.white, lineWidth: 2)
                                    }
                                    .frame(height: 20)
                                }
                                
                                if let nextModelName = nextAnimal.modelName {
                                    SceneView(
                                        scene: {
                                            let scene = SCNScene(named: "art.scnassets/\(nextModelName)")!
                                            scene.background.contents = UIColor(red: 0.16, green: 0.18, blue: 0.2, alpha: 1)
                                            return scene
                                        }(),
                                        options: [.autoenablesDefaultLighting, .allowsCameraControl]
                                    )
                                    .frame(width: geometry.size.width * 0.25, height: geometry.size.height * 0.1)
                                    //.background(Color.white.opacity(0.09))
                                    .cornerRadius(20)
                                    //.padding(.trailing, 50)
                                    .padding(.trailing, geometry.size.width * 0.11)
                                }
                            }
                        }
                        //.padding(.vertical, geometry.size.height * 0.0)
                        .offset(y: -geometry.size.height * 0.07)
                        
                        // Recent Workouts View
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.2)
                                .background(Color.white.opacity(0.09))
                                .cornerRadius(24)
                                .shadow(color: Color.white.opacity(0.5), radius: 50, x: 5, y: 5)
                            VStack {
                                ForEach(firestoreService.recentWorkouts.prefix(2)) { workout in
                                    HStack {
                                        HStack{
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: geometry.size.width * 0.05))
                                            
                                            Text(workout.username)
                                                .foregroundColor(.white)
                                                .font(.custom("Marker Felt", size: geometry.size.width * 0.05))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        //Spacer()
                                        HStack{
                                            Image(systemName: "clock.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: geometry.size.width * 0.05))
                                            
                                            Text("\(timeAgoSinceDate(workout.recentWorkout))")
                                                .foregroundColor(.white)
                                                .font(.custom("Marker Felt", size: geometry.size.width * 0.05))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.75)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                    .padding(.vertical, geometry.size.height * 0.02)
                                    .padding(.horizontal, geometry.size.width * 0.14)
                                }
                            }
                        }
                        .padding(.vertical, geometry.size.height * 0.03)
                        .offset(y: -geometry.size.height * 0.085)
                    }
                    .offset(y: geometry.size.height * -0.02)
                    .onAppear {
                        firestoreService.fetchFriendsRecentWorkouts()
                        firestoreService.fetchUserScore() // Fetch user score on appear
                    }
                }
                //.offset(y: -geometry.size.height * 0.025)
            }
        //}
        //.navigationBarBackButtonHidden(true)
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
    
    // Helper function to get the next animal's model name and points
    func getNextAnimal(for score: Int) -> (modelName: String?, points: Int) {
        switch score {
        case 0..<200:
            return ("cat.usdz", 200)
        case 200..<400:
            return ("dog.usdz", 400)
        case 400..<700:
            return ("deer.usdz", 700)
        case 700..<1000:
            return ("bear.usdz", 1000)
        case 1000..<1500:
            return ("bison.usdz", 1500)
        case 1500..<2000:
            return ("penguin.usdz", 2000)
        case 2000...:
            return (nil, 2000) // max level reached
        default:
            return (nil, 0)
        }
    }
}

func timeAgoSinceDate(_ date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear, .month, .year], from: date, to: now)

    if let year = components.year, year >= 2 {
        return "\(year) years ago"
    } else if let year = components.year, year >= 1 {
        return "Last year"
    } else if let month = components.month, month >= 2 {
        return "\(month) months ago"
    } else if let month = components.month, month >= 1 {
        return "Last month"
    } else if let week = components.weekOfYear, week >= 2 {
        return "\(week) weeks ago"
    } else if let week = components.weekOfYear, week >= 1 {
        return "Last week"
    } else if let day = components.day, day >= 2 {
        return "\(day) days ago"
    } else if let day = components.day, day >= 1 {
        return "Yesterday"
    } else if let hour = components.hour, hour >= 2 {
        return "\(hour) hours ago"
    } else if let hour = components.hour, hour >= 1 {
        return "An hour ago"
    } else if let minute = components.minute, minute >= 2 {
        return "\(minute) minutes ago"
    } else if let minute = components.minute, minute >= 1 {
        return "A minute ago"
    } else {
        return "Just now"
    }
}

#Preview {
    ContentView(selectedTab: .constant(.home), showPlusButton: .constant(true))
}

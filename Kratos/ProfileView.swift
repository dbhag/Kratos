//
//  ContentView.swift
//  Kratos
//
//  Created by Dhruv Bhagavatula on 6/11/24.
//
import SwiftUI
import SceneKit

struct ProfileView: View {
    @ObservedObject var firestoreService = FirestoreService()

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

                    // 3D Model View
                    if let modelName = getModelName(for: firestoreService.userScore) {
                        SceneView(
                            scene: {
                                let scene = SCNScene(named: modelName)!
                                
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
                        .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.2)
                        .background(Color.clear) // Ensure background is clear
                        .cornerRadius(20)
                        .padding(.top, -20)
                    }
                    
                    Spacer()
                    
                    ZStack(alignment: .top) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.45)
                            .background(Color.white.opacity(0.09))
                            .cornerRadius(24)
                            .shadow(color: Color.white.opacity(0.5), radius: 50, x: 5, y: 5)
                        
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.05) {
                            HStack {
                                Text("Longest Streak:")
                                    .font(.custom("Marker Felt", size: geometry.size.width * 0.05))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(firestoreService.longestStreak) weeks")
                                    .font(.custom("Marker Felt", size: geometry.size.width * 0.05))
                                    .foregroundColor(.white)
                            }
                            HStack {
                                Text("Total Workouts:")
                                    .font(.custom("Marker Felt", size: geometry.size.width * 0.05))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(firestoreService.totalWorkouts)")
                                    .font(.custom("Marker Felt", size: geometry.size.width * 0.05))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.top, geometry.size.height * 0.03)
                        .padding(.horizontal, geometry.size.width * 0.1)
                    }
                    .padding(.vertical, -geometry.size.height * 0.2)
                    .offset(y: -geometry.size.height * 0.05)
                    
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            firestoreService.fetchUserStats()
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


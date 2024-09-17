import SwiftUI
import SceneKit

struct FullProgressMapView: View {
    @ObservedObject var firestoreService: FirestoreService
    @Binding var showPlusButton: Bool
    
    init(firestoreService: FirestoreService, showPlusButton: Binding<Bool>) {
        self.firestoreService = firestoreService
        self._showPlusButton = showPlusButton
        // Modify navigation bar appearance globally
        UINavigationBar.appearance().barTintColor = UIColor(red: 0.16, green: 0.18, blue: 0.2, alpha: 1.0)
    }
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.16, green: 0.18, blue: 0.2)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach((0..<7).reversed(), id: \.self) { index in
                                VStack {
                                    if index != 6 {
                                        if isInBetween(for: index) {
                                            HStack {
                                                Text("\(firestoreService.userScore) points")
                                                    .foregroundColor(.yellow)
                                                    .font(.custom("Poppins-Regular", size: geometry.size.width * 0.05))
                                                    .offset(x: geometry.size.width * 0.18, y: geometry.size.height * 0.095)
                                            }
                                        }
                                        Rectangle()
                                            .fill(Color.gray)
                                            .frame(width: geometry.size.width * 0.015, height: geometry.size.height * 0.15)
                                    }
                                    
                                    if let modelName = getModelName(for: scoreForIndex(index)) {
                                        SceneView(
                                            scene: {
                                                let scene = loadOptimizedScene(named: modelName)!
                                                scene.background.contents = UIColor(red: 0.16, green: 0.18, blue: 0.2, alpha: 1)
                                                
                                                    /*if !isUnlocked(for: scoreForIndex(index)) {
                                                    let material = SCNMaterial()
                                                    material.diffuse.contents = UIColor.black
                                                    scene.rootNode.childNodes.first?.geometry?.materials = [material]
                                                }*/
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
                                        .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.2)
                                        .background(Color(red: 0.16, green: 0.18, blue: 0.2))
                                        .cornerRadius(20)
                                    }
                                    Text("\(scoreForIndex(index)) points")
                                        .foregroundColor(.white)
                                        .font(.custom("Poppins-Regular", size: geometry.size.width * 0.05))
                                }
                                .id(index)
                            }
                            .padding()
                        }
                        .padding()
                        .onAppear {
                          scrollToCurrentLevel(proxy: proxy)
                          firestoreService.fetchUserScore()
                          showPlusButton = false
                        }
                        .onDisappear
                        {
                          showPlusButton = true
                        }
                    }
                }
            }
        }
        //.navigationBarTitle("Progress Map", displayMode: .inline)
    }
    
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
    
    /*func isUnlocked(for score: Int) -> Bool {
        return firestoreService.userScore >= score
    }*/

    func isInBetween(for score: Int) -> Bool {
        let nextScore = scoreForIndex(score + 1)
        return firestoreService.userScore > scoreForIndex(score) && firestoreService.userScore < nextScore
    }
    func scoreForIndex(_ index: Int) -> Int {
            switch index {
            case 0:
                return 0
            case 1:
                return 200
            case 2:
                return 400
            case 3:
                return 700
            case 4:
                return 1000
            case 5:
                return 1500
            case 6:
                return 2000
            default:
                return 0
            }
        }
        
        func scoreForNextLevel(_ score: Int) -> Int {
            switch score {
            case 0:
                return 200
            case 200:
                return 400
            case 400:
                return 700
            case 700:
                return 1000
            case 1000:
                return 1500
            case 1500:
                return 2000
            default:
                return score + 200
            }
        }
    func scrollToCurrentLevel(proxy: ScrollViewProxy) {
            let currentLevelIndex = (0..<7).reversed().first { isInBetween(for: scoreForIndex($0)) } ?? 0
            proxy.scrollTo(currentLevelIndex, anchor: .center)
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
    FullProgressMapView(firestoreService: FirestoreService(), showPlusButton: .constant(true))
}

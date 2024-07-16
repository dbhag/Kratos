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
                                                    .font(.custom("Marker Felt", size: geometry.size.width * 0.05))
                                                    .offset(x: geometry.size.width * 0.14, y: geometry.size.height * 0.095)
                                            }
                                        }
                                        Rectangle()
                                            .fill(Color.gray)
                                            .frame(width: geometry.size.width * 0.015, height: geometry.size.height * 0.15)
                                    }
                                    
                                    if let modelName = getModelName(for: scoreForIndex(index)) {
                                        SceneView(
                                            scene: {
                                                let scene = SCNScene(named: modelName)!
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
                                        .font(.custom("Marker Felt", size: geometry.size.width * 0.05))
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
}

#Preview {
    FullProgressMapView(firestoreService: FirestoreService(), showPlusButton: .constant(true))
}

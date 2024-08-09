import SwiftUI
import FirebaseAuth
import FirebaseFirestore

enum Tab {
    case home
    case previousWorkouts
    case leaderboard
    case profile
    case login
    case addFriends
    case newWorkout
    case progress
    case workoutGoals
    case takePhoto
    case feed
    case friendsWorkout
    case workoutDescription
    case chatBot
}

struct MainContainerView: View {
    @State private var selectedTab: Tab = .home
    @State private var streak: Int = 0
    @State private var showPlusButton: Bool = true
    @State private var showStreak: Bool = true
    @State private var isTyping: Bool = false
    @State private var friendID: String = ""
    @State private var selectedWorkouts: [String] = []
    @EnvironmentObject private var firestoreService: FirestoreService
    private let db = Firestore.firestore()
    
    
    var body: some View {
        ZStack {
            NavigationView {
                Group {
                    switch selectedTab {
                    case .home:
                        ContentView(selectedTab: $selectedTab, showPlusButton: $showPlusButton)
                    case .previousWorkouts:
                        PreviousWorkoutsView()
                    case .leaderboard:
                        LeaderBoardView(selectedTab: $selectedTab, friendID: $friendID)
                    case .profile:
                        ProfileView()
                    case .login:
                        LoginView()
                    case .addFriends:
                        AddFriendsView(isTyping: $isTyping)
                    case .newWorkout:
                        NewWorkoutView(selectedWorkouts: $selectedWorkouts, selectedTab: $selectedTab)
                    case .workoutDescription:
                        WorkoutDescriptionView(selectedWorkouts: $selectedWorkouts, selectedTab: $selectedTab, isTyping: $isTyping)
                    case .progress:
                        FullProgressMapView(firestoreService: FirestoreService(), showPlusButton: $showPlusButton)
                    case .workoutGoals:
                        SettingsWorkoutView()
                    case .takePhoto:
                        TakePhotoView(selectedTab: $selectedTab)
                    case .feed:
                        FeedView()
                    case .friendsWorkout:
                        FriendsPrevWorkouts(friendID: $friendID)
                    case .chatBot:
                        ChatbotView(selectedTab: $selectedTab)
                    }
                }
                .navigationBarHidden(true)
                .onChange(of: selectedTab) {
                    print("MainContainerView: selectedTab changed to \(selectedTab)")
                    if selectedTab == .progress || selectedTab == .workoutDescription {
                        showPlusButton = false
                    } else {
                        showPlusButton = true
                    }
                    if selectedTab == .profile || selectedTab == .workoutGoals || selectedTab == .feed || selectedTab == .takePhoto || selectedTab == .workoutDescription
                    {
                        showStreak = false
                    }
                    else
                    {
                        showStreak = true
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear {
                fetchStreak()
            }

            if selectedTab != .login {
                VStack {
                    GeometryReader { geometry in
                        HStack {
                            if streak >= 0 && showPlusButton && showStreak && !isTyping && selectedTab == .home {
                                StreakFlameView(streak: streak)
                                    .frame(width: geometry.size.width * 0.1, height: geometry.size.height * 0.1)
                                    .offset(x: geometry.size.width * 0.47, y: geometry.size.height * 0.0425)
                            }
                            else if selectedTab == .profile && !showStreak
                            {
                                Button(action: {
                                    selectedTab = .workoutGoals
                                })
                                {
                                    Image(systemName: "gear")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .frame(width: geometry.size.width * 0.15, height: geometry.size.height * 0.09)
                                }
                                .offset(x: geometry.size.width * 0.815, y: geometry.size.height * 0.064)
                            }
                            else if selectedTab == .feed && !showStreak
                            {
                                Button(action: {
                                    selectedTab = .profile
                                })
                                {
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .frame(width: geometry.size.width * 0.15, height: geometry.size.height * 0.09)
                                }
                                .offset(x: geometry.size.width * 0.815, y: geometry.size.height * 0.064)
                            }
                            
                            else
                            {
                                Spacer().frame(width: geometry.size.width * 0.1, height: geometry.size.height * 0.1)
                                Spacer().offset(x: geometry.size.width * 0.62, y: geometry.size.height * 0.0425)
                            }
                        }
                    }
                    Spacer()
                    TaskbarView(selectedTab: $selectedTab, showPlusButton: $showPlusButton, streak: $streak, showStreak: $showStreak, isTyping: $isTyping)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func fetchStreak() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let userRef = db.collection("users").document(currentUserID)

        userRef.getDocument { document, error in
            if let document = document, document.exists {
                self.streak = document.data()?["streak"] as? Int ?? 0
            } else {
                print("Document does not exist or error: \(String(describing: error))")
            }
        }
    }
}

struct TaskbarView: View {
    @Binding var selectedTab: Tab
    @Binding var showPlusButton: Bool
    @Binding var streak: Int
    @Binding var showStreak: Bool
    @Binding var isTyping: Bool
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Add Friends button at the top
                HStack {
                    Spacer()
                    if showPlusButton && showStreak && !isTyping && selectedTab != .chatBot {
                        Button(action: {
                            selectedTab = .addFriends
                        }) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width * 0.1, height: geometry.size.width * 0.1)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .contentShape(Rectangle())
                        .offset(x: geometry.size.width * 0.02, y: -geometry.size.height * 1.01) // Adjust the offset as needed
                    }
                }
                .padding(.trailing, geometry.size.width * 0.05)
                
                Spacer()
                
                if selectedTab != .takePhoto && selectedTab != .workoutDescription && !isTyping && selectedTab != .chatBot  {
                    ZStack {
                        Image(.rectangle41)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width)
                        //.padding(.vertical, -geometry.size.height * 0.09)
                            .offset(y: geometry.size.height * 0.07)
                        
                        if showPlusButton && selectedTab != .newWorkout && selectedTab != .profile  {
                            Button(action: {
                                selectedTab = .newWorkout
                            }) {
                                Image(.plus)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.2)
                                    .background(Color.clear)
                                    .contentShape(Rectangle())
                            }
                            .offset(y: -geometry.size.height * 0.08)
                        }
                    }
                    .offset(y: geometry.size.height * 0.23)
                    
                    HStack(spacing: geometry.size.width * 0.15) {
                        Button(action: {
                            selectedTab = .home
                        }) {
                            Image(.frame11)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.11, height: geometry.size.width * 0.11)
                        }
                        Button(action: {
                            selectedTab = .previousWorkouts
                        }) {
                            Image(.iconParkOutlineDumbbell)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.11, height: geometry.size.width * 0.11)
                        }
                        .offset(x: -geometry.size.width * 0.07)
                        Button(action: {
                            selectedTab = .leaderboard
                        }) {
                            Image(.materialSymbolsLightLeaderboardOutlineRounded)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.12, height: geometry.size.width * 0.12)
                        }
                        .offset(x: geometry.size.width * 0.058)
                        Button(action: {
                            selectedTab = .feed
                        }) {
                            Image(systemName: "camera")
                                .resizable()
                                .foregroundColor(.white)
                                .opacity(0.9)
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.09, height: geometry.size.width * 0.09)
                        }
                        .offset(y: geometry.size.height * 0.004)
                    }
                    .padding(.bottom, geometry.size.height * (UIDevice.current.userInterfaceIdiom == .phone ? 0.05 : 0.07))
                    .frame(width: geometry.size.width * 0.9)
                    .offset(x: 0, y: geometry.size.height * 0.095)
                    .opacity(0.75)
                }
            }
        }
    }
}

struct StreakFlameView: View {
    var streak: Int

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(.propane)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text("\(streak)")
                //Text("95")
                    .font(.custom("Marker Felt", size: geometry.size.width * 0.6))
                    .foregroundColor(.white)
                    .offset(x: geometry.size.width * 0.8, y: geometry.size.height * 0.1)
            }
        }
    }
}

#Preview {
    MainContainerView()
        .environmentObject(FirestoreService())
}


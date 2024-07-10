import SwiftUI
import FirebaseAuth
import FirebaseFirestore

enum Tab {
    case home
    case previousWorkouts
    case leaderboard
    case profile
    case login
    case createUsername
    case addFriends
    case newWorkout
    case progress
}

struct MainContainerView: View {
    @State private var selectedTab: Tab = .home
    @State private var streak: Int = 0
    @State private var showPlusButton: Bool = true
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
                        LeaderBoardView()
                    case .profile:
                        ProfileView()
                    case .login:
                        LoginView()
                    case .createUsername:
                        CreateAccountView()
                    case .addFriends:
                        AddFriendsView()
                    case .newWorkout:
                        NewWorkoutView()
                    case .progress:
                        FullProgressMapView(firestoreService: FirestoreService(),showPlusButton: $showPlusButton)
                    }
                    
                }
                .navigationBarHidden(true)
                .onChange(of: selectedTab) { newTab in
                    print("MainContainerView: selectedTab changed to \(newTab)")
                    if newTab == .progress {
                        showPlusButton = false
                    } else {
                        showPlusButton = true
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear {
                fetchStreak()
            }

            if selectedTab != .login && selectedTab != .createUsername {
                VStack {
                    Spacer()
                    TaskbarView(selectedTab: $selectedTab, showPlusButton: $showPlusButton, streak: $streak)
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
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Add Friends button at the top
                HStack {
                    Spacer()
                    if streak > 0 {
                        StreakFlameView(streak: streak)
                        //.frame(width: geometry.size.width * 0.13, height: geometry.size.height * 0.13)
                        //.padding(.leading, geometry.size.width * 0.05)
                    }
                    Spacer()
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
                    .offset(x: geometry.size.width * 0.02, y: -geometry.size.height * 0.0035) // Adjust the offset as needed
                }
                .padding(.trailing, geometry.size.width * 0.05)

                Spacer()

                ZStack {
                    Image(.rectangle41)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                        .padding(.vertical, geometry.size.height * 0.05)

                    if showPlusButton && selectedTab != .newWorkout {
                        Button(action: {
                            selectedTab = .newWorkout
                        }) {
                            Image(.plusplus)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
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
                        Image(.frame1)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.11, height: geometry.size.width * 0.11)
                    }
                    Button(action: {
                        selectedTab = .previousWorkouts
                    }) {
                        Image(.vector)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.1, height: geometry.size.width * 0.1)
                    }
                    .offset(x: -geometry.size.width * 0.07)
                    Button(action: {
                        selectedTab = .leaderboard
                    }) {
                        Image(.vector1)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.09, height: geometry.size.width * 0.09)
                    }
                    .offset(x: geometry.size.width * 0.058)
                    Button(action: {
                        selectedTab = .profile
                    }) {
                        Image(.iconamoonProfile)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.11, height: geometry.size.width * 0.11)
                    }
                    .offset(y: geometry.size.height * 0.004)
                }
                .padding(.bottom, geometry.size.height * (UIDevice.current.userInterfaceIdiom == .phone ? 0.05 : 0.07))
                .frame(width: geometry.size.width * 0.9)
                .offset(x: 0, y: geometry.size.height * 0.08)
                .opacity(0.75)
            }
        }
    }
}

struct StreakFlameView: View {
    var streak: Int

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(.giphy2)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 0.13, height: geometry.size.height * 0.13)
                    .offset(x: 0, y: geometry.size.height * 0.08)

                Text("\(streak)")
                    .font(.custom("Marker Felt", size: geometry.size.width * 0.05))
                    .foregroundColor(.white)
                    .offset(x: 0, y: -geometry.size.height * 0.07)
            }
        }
    }
}

#Preview {
    MainContainerView()
}


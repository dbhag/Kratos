import SwiftUI

enum Tab {
    case home
    case previousWorkouts
    case leaderboard
    case profile
    case login
    case createUsername
    case addFriends
    case newWorkout
}

struct MainContainerView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        ZStack {
            NavigationView {
                Group {
                    switch selectedTab {
                    case .home:
                        ContentView()
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
                    }
                    
                }
                .navigationBarHidden(true)
            }
            .navigationViewStyle(StackNavigationViewStyle())

            if selectedTab != .login && selectedTab != .createUsername {
                TaskbarView(selectedTab: $selectedTab)
            }
        }
    }
}
struct TaskbarView: View {
    @Binding var selectedTab: Tab

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                Image(.rectangle41)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width)
                    .padding(.vertical, geometry.size.height * 0.05)
                    .offset(y: geometry.size.height * 0.34)
                
                if(selectedTab != .newWorkout){
                    Button(action: {
                        selectedTab = .newWorkout
                    }) {
                        Image(.plusplus)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                            .offset(y: geometry.size.height * 0.1)
                            //.padding(.bottom, geometry.size.height * 0.02)
                    }
                }
                
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
                            .offset(x: -geometry.size.width * 0.07)
                    }
                    Button(action: {
                        selectedTab = .leaderboard
                    }) {
                        Image(.vector1)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.09, height: geometry.size.width * 0.09)
                            .offset(x: geometry.size.width * 0.058)
                    }
                    Button(action: {
                        selectedTab = .profile
                    }) {
                        Image(.iconamoonProfile)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.11, height: geometry.size.width * 0.11)
                            .offset(y: geometry.size.height * 0.004)
                    }
                }
                .padding(.bottom, geometry.size.height * (UIDevice.current.userInterfaceIdiom == .phone ? 0.05 : 0.07))
                .frame(width: geometry.size.width * 0.9)
                .offset(x: 0, y: geometry.size.height * 0.08)
                .opacity(0.75)
            }
        }
    }
}

#Preview {
    MainContainerView()
}


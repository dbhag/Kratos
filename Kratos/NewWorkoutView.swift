
import SwiftUI

struct NewWorkoutView: View {
    @State private var isFriendsSelected = true
    @State private var text: String = ""
    @EnvironmentObject var workoutModel: WorkoutModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.16, green: 0.18, blue: 0.2)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Header with Text and Flame Image
                    HStack(spacing: geometry.size.width * 0.05) {
                        Text("New Workout")
                            .font(.custom("AmericanTypewriter", size: geometry.size.width * 0.075))
                            .tracking(0.36)
                            .minimumScaleFactor(0.8)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .offset(x: 0, y: -geometry.size.height * 0.05)
                        
                        Image(.giphy2)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width * 0.13, height: geometry.size.height * 0.13)
                            .offset(x: 0 , y: -geometry.size.height * 0.07)
                    }
                    .padding(.horizontal, geometry.size.width * 0.08)
                    .frame(height: geometry.size.height * 0.1)
                    .padding(.top, geometry.size.height * 0.05)

                    HStack {
                        Text("Lift")
                            .font(.custom("AmericanTypewriter", size: geometry.size.width * 0.05))
                            .foregroundColor(isFriendsSelected ? .black : .gray)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(isFriendsSelected ? Color.white : Color(red: 0.16, green: 0.18, blue: 0.2))
                            .cornerRadius(20)
                            .onTapGesture {
                                isFriendsSelected = true
                            }

                        Text("Cardio")
                            .font(.custom("AmericanTypewriter", size: geometry.size.width * 0.05))
                            .foregroundColor(!isFriendsSelected ? .white : .gray)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(!isFriendsSelected ? Color.orange : Color(red: 0.16, green: 0.18, blue: 0.2))
                            .cornerRadius(20)
                            .onTapGesture {
                                isFriendsSelected = false
                            }
                    }
                    .padding(.bottom, 10)
                    .padding(.top, -geometry.size.height * 0.03)
                    
                    Spacer()
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.55)
                            .background(Color.white.opacity(0.09))
                            .cornerRadius(24)
                            .shadow(color: Color.white.opacity(0.5), radius: 50, x: 5, y: 5)

                        TextEditor(text: $text)
                            .padding()
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.55)
                            .font(Font.custom("AmericanTypewriter", size: geometry.size.width * 0.06))
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.09), lineWidth: 1)
                            )
                    }
                    .padding(.vertical, geometry.size.height * 0.05)
                    
                    Spacer()
                    
                    Button(action: {
                        if !text.isEmpty {
                            workoutModel.workouts.append(text)
                            text = ""
                        }
                    }) {
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.16, green: 0.18, blue: 0.2))
                            .padding()
                            .frame(width: 220, height: 60)
                            .background(Color.white)
                            .cornerRadius(15.0)
                            .shadow(color: .gray, radius: 5, x: 0, y: 5)
                            .offset(y: -geometry.size.height * 0.03)
                    }
                    .padding(.bottom, geometry.size.height * 0.02)
                    
                    Image(.rectangle41)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.9)
                            .offset(y: geometry.size.height * 0.1)
                            .padding(.vertical, geometry.size.height * 0.02)
                    
                    Spacer()

                    HStack(spacing: geometry.size.width * 0.15) {
                        NavigationLink(destination: ContentView()) {
                            Image(.frame1)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.11, height: geometry.size.width * 0.11)
                        }

                        Image(.vector)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.1, height: geometry.size.width * 0.1)
                            .offset(x: -geometry.size.width * 0.07)

                        NavigationLink(destination: LeaderBoardView()) {
                            Image(.vector1)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.09, height: geometry.size.width * 0.09)
                                .offset(x: geometry.size.width * 0.058)
                        }

                        NavigationLink(destination: ProfileView()) {
                            Image(.iconamoonProfile)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.11, height: geometry.size.width * 0.11)
                                .offset(y: geometry.size.height * 0.004)
                        }
                    }
                    .padding(.bottom, geometry.size.height * (UIDevice.current.userInterfaceIdiom == .phone ? 0.05 : 0.07))
                    .frame(width: geometry.size.width * 0.9)
                    .offset(x: 0, y: geometry.size.height * -0.06)
                    .opacity(0.75)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NewWorkoutView()
}

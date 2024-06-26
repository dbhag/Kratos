//
//  ContentView.swift
//  Kratos
//
//  Created by Dhruv Bhagavatula on 6/11/24.
// 
import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    @ObservedObject var firestoreService = FirestoreService()
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color(red: 0.16, green: 0.18, blue: 0.2)
                        .edgesIgnoringSafeArea(.all)
                    RadialGradient(gradient: Gradient(colors: [
                        Color.white.opacity(0.5),
                        Color.white.opacity(0.0)
                    ]), center: .center, startRadius: 50, endRadius: 300)
                    .blendMode(.overlay)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        // Header with Text and Flame Image
                        HStack(spacing: geometry.size.width * 0.05) {
                            Text("Kratos")
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
                                .offset(x: 0, y: -geometry.size.height * 0.07)
                            NavigationLink(destination: AddFriendsView()) {
                                Text("Add Friends")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.08)
                        .frame(height: geometry.size.height * 0.1)
                        .padding(.top, geometry.size.height * 0.05)
                        
                        VStack{
                            Spacer()
                            NavigationLink(destination: NewWorkoutView())
                            {
                                Image(.plusplus)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                                    .padding(.bottom, geometry.size.height * 0.02)
                            }
                            .offset(y: geometry.size.height * 0.68)
                            .buttonStyle(PlainButtonStyle())
                            
                            Image(.rectangle41)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width)
                                .padding(.vertical, geometry.size.height * 0.05)
                                .offset(y: geometry.size.height * 0.58)
                            
                            Spacer()
                        }
                        
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
                                        Text(workout.username)
                                            .foregroundColor(.white)
                                            .font(.custom("AmericanTypewriter", size: geometry.size.width * 0.05))
                                            .padding(.trailing, 75)
    
                                        Text("\(timeAgoSinceDate(workout.recentWorkout))")
                                            .foregroundColor(.white)
                                            .font(.custom("AmericanTypewriter", size: geometry.size.width * 0.05))
                                    }
                                    .padding(.vertical, 5)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical, geometry.size.height * 0.05)
                        
                        Spacer()
                        
                        HStack(spacing: geometry.size.width * 0.15) {
                            NavigationLink(destination: ContentView())
                            {
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
                            NavigationLink(destination: LeaderBoardView())
                            {
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
                        .offset(x: 0, y: geometry.size.height * 0.08)
                        .opacity(0.75)
                    }
                    .onAppear {
                        firestoreService.fetchFriendsRecentWorkouts()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
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
    ContentView()
}

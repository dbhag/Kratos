//
//  LeaderBoardView.swift
//  Kratos
//
//  Created by Dhruv Bhagavatula on 6/17/24.
//

import SwiftUI

struct LeaderBoardView: View {
    @ObservedObject var firestoreService = FirestoreService()
    var body: some View {
            GeometryReader { geometry in
                ZStack {
                    Color(red: 0.16, green: 0.18, blue: 0.2)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        // Header with Text and Flame Image
                        HStack(spacing: geometry.size.width * 0.05) {
                            Text("Leaderboard")
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
                        }
                        .padding(.horizontal, geometry.size.width * 0.08)
                        .frame(height: geometry.size.height * 0.1)
                        .padding(.top, geometry.size.height * 0.05)

                        Text("Friends")
                            .font(.custom("AmericanTypewriter", size: geometry.size.width * 0.05))
                            .foregroundColor(.black)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.white)
                            .cornerRadius(20)
                            .padding(.bottom, 10)
                            .padding(.top, -geometry.size.height * 0.03)
                        
                        List {
                            ForEach(Array(firestoreService.leaderboardEntries.enumerated()), id: \.element.id) { index, entry in
                                HStack {
                                    Text(entry.name)
                                        .font(.custom("AmericanTypewriter", size: geometry.size.width * 0.05))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(entry.score)")
                                        .font(.custom("AmericanTypewriter", size: geometry.size.width * 0.05))
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(
                                    index == 0 ? Color.yellow : // Gold for 1st place
                                    index == 1 ? Color.gray :  // Silver for 2nd place
                                    index == 2 ? Color.brown : // Bronze for 3rd place
                                    Color(red: 0.16, green: 0.18, blue: 0.2) // Default background color
                                )
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 5)
                            }
                            .listRowBackground(Color(red: 0.16, green: 0.18, blue: 0.2))
                        }
                        .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.6)
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
                        .scrollContentBackground(.hidden)
                        .padding(.top, geometry.size.height * 0.01)

                        Image(.rectangle41)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.3)
                            .padding(.vertical, geometry.size.height * 0.03)
                        
                        Spacer()
                           
                        Image(.plusplus)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                            .padding(.bottom, geometry.size.height * 0.02)
                            .offset(y: -geometry.size.height * 0.32)
        
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
                                    .offset(y: geometry.size.height * 0.001)
                            }
                        }
                        .padding(.bottom, geometry.size.height * (UIDevice.current.userInterfaceIdiom == .phone ? 0.05 : 0.07))
                        .frame(width: geometry.size.width * 0.9)
                        .offset(x: 0, y: -geometry.size.height * 0.36)
                        .opacity(0.75)
                    }
                    .onAppear {
                        firestoreService.fetchFriendsLeaderboardEntries()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
}

#Preview {
    LeaderBoardView()
}

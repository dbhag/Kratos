//
//  ContentView.swift
//  Kratos
//
//  Created by Dhruv Bhagavatula on 6/11/24.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
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
                        }
                        .padding(.horizontal, geometry.size.width * 0.08)
                        .frame(height: geometry.size.height * 0.1)
                        .padding(.top, geometry.size.height * 0.05)
                        
                        VStack{
                            Spacer()
                            Image(.plusplus)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                                .padding(.bottom, geometry.size.height * 0.02)
                                .offset(y: geometry.size.height * 0.68)
                            
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
                            
                            Text("Friend Info")
                                .font(Font.custom("AmericanTypewriter", size: geometry.size.width * 0.06))
                                .tracking(0.38)
                                .lineSpacing(24)
                                .foregroundColor(.white)
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
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
#Preview {
    ContentView()
}

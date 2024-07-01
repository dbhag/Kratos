//
//  ContentView.swift
//  Kratos
//
//  Created by Dhruv Bhagavatula on 6/11/24.
//
import SwiftUI

struct ProfileView: View {
    var body: some View {
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
                        Text("My Profile")
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
                    
                    Spacer()
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.45)
                            .background(Color.white.opacity(0.09))
                            .cornerRadius(24)
                            .shadow(color: Color.white.opacity(0.5), radius: 50, x: 5, y: 5)

                        Text("Stats")
                            .font(Font.custom("AmericanTypewriter", size: geometry.size.width * 0.06))
                            .tracking(0.38)
                            .lineSpacing(24)
                            .foregroundColor(.white)
                    }
                    .offset(y: geometry.size.height * 0.16)
                    .padding(.vertical, geometry.size.height * 0.05)
                    
                    Spacer()
                    
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
#Preview {
    ProfileView()
}


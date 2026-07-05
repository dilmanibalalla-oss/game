//
//  GamesHubView.swift
//  games
//
//  Created by student5 on 2026-07-05.
//

import SwiftUI

struct GamesHubView: View {
    var body: some View {
        ZStack {
            Color.pink.opacity(0.2).ignoresSafeArea()
            
            VStack(spacing: 25) {
                VStack(spacing: 20) {
                    Text("Games Hub")
                        .font(.system(size: 50, weight: .black, design: .rounded))
                    
                    Text("Select a Game to Play")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                .padding(.bottom, 35)
                
                VStack(spacing: 30) {
                    NavigationLink(destination: Text("Tap Frenzy Game View")) {
                        GameButton(title: "Tap Frenzy", subtitle: "Fast-paced clicking action!", icon: "hand.tap.fill", color: .blue)
                    }
                    
                    NavigationLink(destination: Text("Light It Up Game View")) {
                        GameButton(title: "Light It Up", subtitle: "Whack-a-mole precision tiles!", icon: "lightbulb.fill", color: .purple)
                    }
                    
                    NavigationLink(destination: Text("Quiz Rush Game View")) {
                        GameButton(title: "Quiz Rush", subtitle: "Trivia powered by live API!", icon: "questionmark.circle.fill", color: .orange)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
        }
    }
}

// Helper View
struct GameButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2).bold()
                Text(subtitle)
                    .font(.caption)
                    .opacity(0.8)
            }
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color)
        .foregroundColor(.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.black, lineWidth: 2))
    }
}

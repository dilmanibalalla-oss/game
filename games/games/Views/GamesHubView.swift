//
//  GamesHubView.swift
//  games
//
//  Created by student5 on 2026-07-05.
//

import SwiftUI

struct GamesHubView: View {
    @State private var showHighScores = false
    
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
                
                VStack(spacing: 40) {
                    NavigationLink(destination: TapFrenzyView()) {
                        GameButton(title: "Tap Frenzy", subtitle: "Fast-paced clicking action!", icon: "hand.tap.fill", color: .blue)
                    }.padding(10)
                    
                    NavigationLink(destination: LightItUpView()) {
                        GameButton(title: "Light It Up", subtitle: "Whack-a-mole precision tiles!", icon: "lightbulb.fill", color: .purple)
                    }.padding(10)
                    
                    NavigationLink(destination: QuizView()) {
                        GameButton(title: "Quiz Rush", subtitle: "Trivia powered by live API!", icon: "questionmark.circle.fill", color: .orange)
                    }.padding(10)
                    
                    Button { showHighScores = true } label: {
                        GameButton(title: "High Scores", subtitle: "Your best scores across all games", icon: "trophy.fill", color: .green)
                    }
                    .padding(10)
                }
                
                Spacer()
            }
        }
        .onAppear { HighScoreKeys.migrateIfNeeded() }
        .sheet(isPresented: $showHighScores) {
            HighScoresView()
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

#Preview{
    
    GamesHubView()
}

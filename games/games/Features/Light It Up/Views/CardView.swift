import SwiftUI

struct CardView: View {
    let card: Card
    let onTap: () -> Void

    private let holeBrown = Color(red: 0.35, green: 0.20, blue: 0.10)
    private let holeDarker = Color(red: 0.20, green: 0.12, blue: 0.05)

    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    gradient: Gradient(colors: [holeBrown, holeDarker]),
                    center: .center,
                    startRadius: 5,
                    endRadius: 50
                ))

            if card.isLit {
              
                let activeColor = card.litColor ?? .yellow
                
                Circle()
                    .fill(activeColor.opacity(0.9))
                    .blur(radius: 8)
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .padding(10)
            }
        }
        .overlay(Circle().stroke(Color.black.opacity(0.8), lineWidth: 6))
        .padding(10)
        .aspectRatio(1.0, contentMode: .fit)
        .onTapGesture(perform: onTap)
    }
}



import SwiftUI

struct CardView: View {
    let card: Card
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(card.isLit ? Color.blue : Color.gray.opacity(0.2))
            .shadow(color: card.isLit ? .blue.opacity(0.6) : .clear, radius: card.isLit ? 10 : 0)
            .scaleEffect(card.isLit ? 1.05 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: card.isLit)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(card.isLit ? Color.blue : Color.gray.opacity(0.4), lineWidth: 2)
            )
    }
}

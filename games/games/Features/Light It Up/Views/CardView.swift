import SwiftUI
struct CardView: View {
    let card: Card
    let level: Int
    let round: Int 
    
    private var litColor: Color {
        switch round {
        case 1:
            return .blue
        case 2:
            return (card.id % 2 == 0) ? .blue : .red
        case 3:
            let colors: [Color] = [.blue, .red, .green]
            return colors[card.id % 3]
        default:
            return .blue
        }
    }
    
    var body: some View {
        let glow = card.isLit ? CGFloat(10 + (level * 2)) : 0
        
        RoundedRectangle(cornerRadius: 12)
            .fill(card.isLit ? litColor : Color.gray.opacity(0.2))
            .shadow(color: card.isLit ? litColor.opacity(0.6) : .clear, radius: glow)
            .scaleEffect(card.isLit ? 1.05 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: card.isLit)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(card.isLit ? litColor : Color.gray.opacity(0.4), lineWidth: 2)
            )
    }
}

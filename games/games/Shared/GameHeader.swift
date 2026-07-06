import SwiftUI

struct GameTitleHeader: View {
    let title: String
    let textColor: Color

    var body: some View {
        Text(title)
            .font(AppFonts.gameTitle)
            .foregroundColor(textColor)
    }
}

struct GameOverHeader: View {
    let title: String
    var textColor: Color = .primary

    var body: some View {
        Text(title)
            .font(.largeTitle.bold())
            .foregroundColor(textColor)
    }
}

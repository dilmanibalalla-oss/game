import SwiftUI

struct GameButton: View {
    let title: String
    let accentColor: Color
    let action: () -> Void

    private var foregroundColor: Color {
        accentColor == AppColors.quiz ? AppColors.tapFrenzy : .white
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .padding()
                .background(accentColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(10)
        }
    }
}

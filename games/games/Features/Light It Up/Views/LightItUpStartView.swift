import SwiftUI

struct LightItUpStartView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 25) {
            GameTitleHeader(title: "Light It Up", textColor: AppColors.lightItUp2)
            GameButton(title: "Start Game", accentColor: AppColors.lightItUp, action: onStart)
        }
    }
}

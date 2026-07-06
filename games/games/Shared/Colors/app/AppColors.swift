import SwiftUI

enum AppColors {
    static let skyTop = Color(hex: "6F68A7")
    static let skyMid = Color(hex: "9B8FD5")
    static let skyHorizon = Color(hex: "D1A8D4")
    static let cloudTint = Color(hex: "F2C8D1")

    static let panelTint = Color(red: 0.94, green: 0.91, blue: 0.98)
    static let cardBg = Color(red: 0.97, green: 0.95, blue: 1.00)
    static let textPrimary = Color(red: 0.25, green: 0.24, blue: 0.36)
    static let textSecondary = Color(red: 0.50, green: 0.45, blue: 0.58)
    static let warmAccent = Color(red: 0.98, green: 0.72, blue: 0.69)

    static let chartColors: [Color] = [
        skyTop, skyHorizon, skyMid, cloudTint, Color(hex: "8A81C6")
    ]

    static let tapFrenzy = Color(hex: "00204A")
 
    static let tapFrenzy2 = Color(hex: "FFFFFF")
    static let lightItUp = Color(hex: "7BB369")
    static let lightItUp2 = Color(hex: "FFFFFF")
    static let quiz = Color(hex: "FFD1DC")
    static let quiz2 = Color(hex: "FFFFFF")

}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        self.init(red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: Double(rgbValue & 0x0000FF) / 255.0)
    }
}

extension LinearGradient {
    static var skyBackground: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [AppColors.skyTop, AppColors.skyMid, AppColors.skyHorizon, AppColors.cloudTint]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

import SwiftUI

struct Card: Identifiable, Equatable {
    let id: Int
    var isLit: Bool = false
    var litColor: Color? = nil // Add this line
}

import SwiftUI

enum TeaPalette {
    static let background = Color(red: 0.965, green: 0.957, blue: 0.925)
    static let card = Color(red: 0.995, green: 0.991, blue: 0.971)
    static let green = Color(red: 0.267, green: 0.376, blue: 0.310)
    static let softGreen = Color(red: 0.851, green: 0.886, blue: 0.820)
    static let sage = Color(red: 0.914, green: 0.929, blue: 0.875)
    static let apricot = Color(red: 0.941, green: 0.886, blue: 0.780)
    static let ink = Color(red: 0.157, green: 0.188, blue: 0.157)
    static let secondaryInk = Color(red: 0.404, green: 0.439, blue: 0.392)
}

struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

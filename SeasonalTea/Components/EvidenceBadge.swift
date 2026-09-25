import SwiftUI

struct EvidenceBadge: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption.weight(.medium))
            .foregroundStyle(TeaPalette.green)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(TeaPalette.sage, in: Capsule())
            .fixedSize(horizontal: false, vertical: true)
    }
}

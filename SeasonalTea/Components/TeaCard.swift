import SwiftUI

struct TeaCard: View {
    let tea: Tea

    private var ingredientLine: String {
        tea.ingredients.map(\.name).prefix(4).joined(separator: " · ")
    }

    var body: some View {
        NavigationLink(value: tea) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(TeaPalette.sage)
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: tea.type == .compound ? "leaf" : "cup.and.saucer")
                            .font(.title3)
                            .foregroundStyle(TeaPalette.green)
                    }

                VStack(alignment: .leading, spacing: 7) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(tea.name)
                            .font(.headline)
                            .foregroundStyle(TeaPalette.ink)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 4)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(TeaPalette.secondaryInk.opacity(0.65))
                    }

                    if !ingredientLine.isEmpty {
                        Text(ingredientLine)
                            .font(.subheadline)
                            .foregroundStyle(TeaPalette.secondaryInk)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }

                    Text(tea.benefit)
                        .font(.caption)
                        .foregroundStyle(TeaPalette.secondaryInk)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    EvidenceBadge(title: tea.evidenceLabel)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TeaPalette.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(TeaPalette.green.opacity(0.07), lineWidth: 1)
            }
        }
        .buttonStyle(PressableCardStyle())
    }
}

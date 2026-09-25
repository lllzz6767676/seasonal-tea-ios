import SwiftUI

struct TeaDetailView: View {
    let tea: Tea

    private var preparation: String {
        tea.recipe.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "原资料未提供统一冲泡参数。"
            : tea.recipe
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                hero

                SectionCard(title: "原料", symbol: "leaf") {
                    if tea.ingredients.isEmpty {
                        Text("原资料未列出具体原料。")
                            .foregroundStyle(TeaPalette.secondaryInk)
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(tea.ingredients) { ingredient in
                                HStack(alignment: .firstTextBaseline, spacing: 10) {
                                    Circle()
                                        .fill(TeaPalette.green.opacity(0.7))
                                        .frame(width: 6, height: 6)
                                    Text(ingredient.name)
                                        .foregroundStyle(TeaPalette.ink)
                                    Spacer(minLength: 6)
                                    if !ingredient.amount.isEmpty {
                                        Text(ingredient.amount)
                                            .foregroundStyle(TeaPalette.secondaryInk)
                                    }
                                }
                                .font(.body)
                            }
                        }
                    }
                }

                SectionCard(title: "功效 / 食养定位", symbol: "text.book.closed") {
                    Text(tea.benefit)
                        .font(.body)
                        .foregroundStyle(TeaPalette.ink)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }

                SectionCard(title: "配方与制作", symbol: "cup.and.saucer") {
                    Text(preparation)
                        .font(.body)
                        .foregroundStyle(TeaPalette.ink)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }

                SectionCard(title: "证据说明", symbol: "checkmark.seal") {
                    VStack(alignment: .leading, spacing: 10) {
                        EvidenceBadge(title: tea.evidenceLabel)
                        Text(tea.evidenceSummary)
                            .font(.body)
                            .foregroundStyle(TeaPalette.ink)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                SectionCard(title: "注意事项", symbol: "exclamationmark.shield") {
                    VStack(alignment: .leading, spacing: 10) {
                        if tea.cautions.isEmpty {
                            Text("原资料未列出额外注意事项。")
                                .foregroundStyle(TeaPalette.secondaryInk)
                        } else {
                            ForEach(tea.cautions, id: \.self) { caution in
                                HStack(alignment: .top, spacing: 9) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 5))
                                        .foregroundStyle(TeaPalette.green.opacity(0.75))
                                        .padding(.top, 8)
                                    Text(caution)
                                        .foregroundStyle(TeaPalette.ink)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .font(.body)
                            }
                        }

                        if tea.type == .compound {
                            Text("仅作为食养参考，不替代医学诊断、药物治疗或医生建议。")
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(TeaPalette.green)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 3)
                        }
                    }
                }

                SectionCard(title: "来源", symbol: "books.vertical") {
                    VStack(alignment: .leading, spacing: 9) {
                        Text(tea.sourceTitle)
                            .font(.body)
                            .foregroundStyle(TeaPalette.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        if let sourceURL = tea.sourceURL, let url = URL(string: sourceURL) {
                            Link(destination: url) {
                                Label("查看原始资料", systemImage: "arrow.up.right.square")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(TeaPalette.green)
                            }
                            .padding(.top, 2)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 32)
            .frame(maxWidth: 660)
            .frame(maxWidth: .infinity)
        }
        .background(TeaPalette.background.ignoresSafeArea())
        .navigationTitle(tea.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("分享茶饮资料")
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "leaf.fill")
                    .font(.title)
                    .foregroundStyle(TeaPalette.green)
                    .frame(width: 58, height: 58)
                    .background(TeaPalette.softGreen, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                Spacer()
                EvidenceBadge(title: tea.evidenceLabel)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(tea.name)
                    .font(.system(.largeTitle, design: .serif, weight: .semibold))
                    .foregroundStyle(TeaPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(tea.kind)
                    .font(.subheadline)
                    .foregroundStyle(TeaPalette.secondaryInk)
            }
        }
        .padding(21)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TeaPalette.sage.opacity(0.78), in: RoundedRectangle(cornerRadius: 25, style: .continuous))
    }

    private var shareText: String {
        "\(tea.name)｜\(tea.kind)\n\(tea.benefit)\n來源：\(tea.sourceTitle)"
    }
}

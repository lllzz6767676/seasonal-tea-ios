import SwiftUI

struct HomeView: View {
    let teas: [Tea]
    private let date: Date
    private let solarTerm: SolarTerm
    private let recommendation: RecommendationResult?

    init(teas: [Tea]) {
        self.teas = teas
        let date = Date()
        self.date = date
        let term = SolarTermService().current(for: date)
        solarTerm = term
        recommendation = RecommendationService().recommendation(
            for: date,
            term: term,
            season: term.season,
            allowedTeas: teas
        )
    }

    private var formattedDate: String {
        date.formatted(
            Date.FormatStyle()
                .year()
                .month(.twoDigits)
                .day(.twoDigits)
                .locale(Locale(identifier: "zh_CN"))
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                if let recommendation {
                    recommendationCard(recommendation)
                } else {
                    ContentUnavailableView(
                        "今日暂无推荐",
                        systemImage: "leaf",
                        description: Text("本地数据中没有可进入季节推荐的茶饮。你仍可进入茶库浏览全部资料。")
                    )
                }

                seasonNote
                libraryButton

                Text("节气用于季节化饮品推荐。茶饮资料中的健康信息仅按原有证据范围呈现。")
                    .font(.footnote)
                    .foregroundStyle(TeaPalette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 28)
            .frame(maxWidth: 620)
            .frame(maxWidth: .infinity)
        }
        .background(TeaPalette.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .center) {
                Text("今日推荐")
                    .font(.system(.largeTitle, design: .serif, weight: .semibold))
                    .foregroundStyle(TeaPalette.ink)
                Spacer()
                Image(systemName: "sun.max")
                    .font(.title2)
                    .foregroundStyle(TeaPalette.green)
                    .padding(12)
                    .background(TeaPalette.sage, in: Circle())
                    .accessibilityHidden(true)
            }

            Text("\(formattedDate)  ·  \(solarTerm.name) · \(solarTerm.season)季")
                .font(.subheadline)
                .foregroundStyle(TeaPalette.secondaryInk)
        }
    }

    private func recommendationCard(_ result: RecommendationResult) -> some View {
        VStack(alignment: .leading, spacing: 19) {
            HStack {
                Text("今日推荐养生茶")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(TeaPalette.green)
                Spacer()
                Image(systemName: "cup.and.saucer.fill")
                    .font(.title2)
                    .foregroundStyle(TeaPalette.green)
                    .frame(width: 52, height: 52)
                    .background(.white.opacity(0.62), in: Circle())
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(result.tea.name)
                    .font(.system(.largeTitle, design: .serif, weight: .semibold))
                    .foregroundStyle(TeaPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(result.tea.ingredients.map(\.name).joined(separator: " · "))
                    .font(.body)
                    .foregroundStyle(TeaPalette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("为什么今天推荐？")
                    .font(.headline)
                    .foregroundStyle(TeaPalette.ink)
                Text(result.reason)
                    .font(.body)
                    .foregroundStyle(TeaPalette.secondaryInk)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            NavigationLink(value: result.tea) {
                HStack(spacing: 8) {
                    Text("查看详情")
                    Image(systemName: "arrow.right")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TeaPalette.green)
            }
            .buttonStyle(PressableCardStyle())
        }
        .padding(23)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            LinearGradient(
                colors: [TeaPalette.softGreen, TeaPalette.sage, TeaPalette.card],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.8), lineWidth: 1)
        }
    }

    private var seasonNote: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "calendar")
                .foregroundStyle(TeaPalette.green)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 5) {
                Text("节气与饮用提示")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(TeaPalette.ink)
                Text(solarTerm.recommendationContext)
                    .font(.subheadline)
                    .foregroundStyle(TeaPalette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(17)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TeaPalette.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var libraryButton: some View {
        NavigationLink {
            TeaLibraryView(teas: teas)
        } label: {
            HStack {
                Image(systemName: "square.grid.2x2")
                Text("进入养生茶库")
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "arrow.right")
            }
            .font(.body)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .frame(minHeight: 58)
            .background(TeaPalette.green, in: RoundedRectangle(cornerRadius: 19, style: .continuous))
        }
        .buttonStyle(PressableCardStyle())
    }
}

import SwiftUI

struct TeaLibraryView: View {
    let teas: [Tea]
    private let searchService: TeaSearchService
    @State private var searchText = ""
    @State private var searchResults: [Tea] = []
    @State private var searchPending = false
    @State private var categorySelectionFeedback = 0

    private let columns = [GridItem(.flexible(), spacing: 13), GridItem(.flexible(), spacing: 13)]
    private var isSearching: Bool { !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    init(teas: [Tea]) {
        self.teas = teas
        searchService = TeaSearchService(teas: teas)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 23) {
                if isSearching {
                    searchContent
                } else {
                    categoryContent
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 28)
            .frame(maxWidth: 660)
            .frame(maxWidth: .infinity)
        }
        .background(TeaPalette.background.ignoresSafeArea())
        .navigationTitle("养生茶库")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "搜索茶名、功效或原料")
        .autocorrectionDisabled()
        .task(id: searchText) {
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !query.isEmpty else {
                searchResults = []
                searchPending = false
                return
            }
            searchResults = []
            searchPending = true
            do {
                try await Task.sleep(for: .milliseconds(180))
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            searchResults = searchService.search(query)
            searchPending = false
        }
    }

    private var categoryContent: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 6) {
                Text("今天想喝点什么？")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(TeaPalette.ink)
                Text("按主题浏览本地收录的茶饮与食养资料。")
                    .font(.subheadline)
                    .foregroundStyle(TeaPalette.secondaryInk)
            }

            LazyVGrid(columns: columns, spacing: 13) {
                ForEach(TeaCategory.all) { category in
                    let matching = teas.filter { $0.categories.contains(category.name) }
                    NavigationLink {
                        TeaCategoryView(category: category, teas: matching)
                    } label: {
                        categoryCard(category, count: matching.count)
                    }
                    .buttonStyle(PressableCardStyle())
                    .simultaneousGesture(TapGesture().onEnded {
                        categorySelectionFeedback += 1
                    })
                    .sensoryFeedback(.selection, trigger: categorySelectionFeedback)
                }
            }

            HStack(spacing: 10) {
                Image(systemName: "leaf")
                    .foregroundStyle(TeaPalette.green)
                Text("共收录 \(teas.count) 款：\(teas.filter { $0.type == .single }.count) 款单品饮品与 \(teas.filter { $0.type == .compound }.count) 款复方食养资料。")
                    .font(.footnote)
                    .foregroundStyle(TeaPalette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TeaPalette.sage.opacity(0.68), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private func categoryCard(_ category: TeaCategory, count: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: category.symbol)
                .font(.title3)
                .foregroundStyle(TeaPalette.green)
                .frame(width: 39, height: 39)
                .background(TeaPalette.sage, in: RoundedRectangle(cornerRadius: 13, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(category.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(TeaPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(3)
                Text("\(count) 款")
                    .font(.caption)
                    .foregroundStyle(TeaPalette.secondaryInk)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 126, alignment: .leading)
        .padding(15)
        .background(TeaPalette.card, in: RoundedRectangle(cornerRadius: 21, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 21, style: .continuous)
                .stroke(TeaPalette.green.opacity(0.07), lineWidth: 1)
        }
    }

    @ViewBuilder
    private var searchContent: some View {
        if searchPending {
            ProgressView()
                .tint(TeaPalette.green)
                .frame(maxWidth: .infinity)
                .padding(.top, 54)
        } else if searchResults.isEmpty {
            ContentUnavailableView(
                "暂时没有找到相关茶饮",
                systemImage: "leaf",
                description: Text("试试搜索“菊花”“睡眠”或“血脂”。")
            )
            .padding(.top, 36)
            .frame(maxWidth: .infinity)
        } else {
            VStack(alignment: .leading, spacing: 14) {
                Text("找到 \(searchResults.count) 款")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(TeaPalette.secondaryInk)
                LazyVStack(spacing: 12) {
                    ForEach(searchResults) { tea in
                        TeaCard(tea: tea)
                    }
                }
            }
            .transition(.opacity)
            .animation(.easeOut(duration: 0.16), value: searchResults.count)
        }
    }
}

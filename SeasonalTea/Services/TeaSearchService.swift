import Foundation

struct TeaSearchService {
    private let indexedTeas: [(tea: Tea, document: String)]

    init(teas: [Tea]) {
        indexedTeas = teas.map { ($0, $0.searchDocument) }
    }

    func search(_ query: String) -> [Tea] {
        let normalized = query
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return [] }
        return indexedTeas.compactMap { $0.document.contains(normalized) ? $0.tea : nil }
    }
}

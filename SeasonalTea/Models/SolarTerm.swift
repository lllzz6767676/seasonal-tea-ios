import Foundation

struct SolarTerm: Identifiable, Hashable {
    let name: String
    let season: String
    let startDate: Date
    let recommendationContext: String

    var id: String { name }
}

import Foundation

struct RecommendationResult {
    let tea: Tea
    let reason: String
}

struct RecommendationService {
    func recommendation(
        for date: Date,
        term: SolarTerm,
        season: String,
        allowedTeas: [Tea]
    ) -> RecommendationResult? {
        let pool = allowedTeas.filter { $0.seasonRecommendable && $0.type == .single }
        guard !pool.isEmpty else { return nil }

        let seasonalPreferences: [String: [String]] = [
            "春": ["green", "low_caffeine_green", "hibiscus"],
            "夏": ["cold_brew", "hibiscus", "green"],
            "秋": ["rooibos", "hibiscus", "black_tea"],
            "冬": ["ginger", "rooibos", "black_tea"]
        ]
        let preferredIDs = Set(seasonalPreferences[season] ?? [])
        let seasonalPool = pool.filter { preferredIDs.contains($0.id) }
        let candidates = seasonalPool.isEmpty ? pool : seasonalPool

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current
        let day = calendar.ordinality(of: .day, in: .era, for: date) ?? 0
        let tea = candidates[day % candidates.count]
        let reason = "当前为\(term.name)节气、\(season)季。\(term.recommendationContext) 今天从适合这一季节饮用场景的茶饮中选择；具体定位与注意事项请查看详情。"
        return RecommendationResult(tea: tea, reason: reason)
    }
}

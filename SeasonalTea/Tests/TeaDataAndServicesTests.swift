import XCTest
@testable import SeasonalTea

final class TeaDataAndServicesTests: XCTestCase {
    private var teas: [Tea] { TeaRepository.shared.teas }

    override func setUpWithError() throws {
        XCTAssertNil(TeaRepository.shared.loadError)
        XCTAssertEqual(teas.count, 60, "The app bundle must contain all 60 tea records.")
    }

    func testAllRecordsAreCompleteAndPreserved() {
        XCTAssertEqual(Set(teas.map(\.id)).count, 60, "Tea IDs must be unique.")
        XCTAssertEqual(teas.filter { $0.type == .single }.count, 30)
        XCTAssertEqual(teas.filter { $0.type == .compound }.count, 30)

        for tea in teas {
            XCTAssertFalse(tea.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, tea.id)
            XCTAssertFalse(tea.categories.isEmpty, tea.id)
            XCTAssertFalse(tea.ingredients.isEmpty, tea.id)
            XCTAssertFalse(tea.benefit.isEmpty, tea.id)
            XCTAssertFalse(tea.recipe.isEmpty, tea.id)
            XCTAssertFalse(tea.evidenceLabel.isEmpty, tea.id)
            XCTAssertFalse(tea.evidenceSummary.isEmpty, tea.id)
            XCTAssertFalse(tea.sourceTitle.isEmpty, tea.id)

            if let sourceURL = tea.sourceURL {
                XCTAssertEqual(URL(string: sourceURL)?.scheme, "https", tea.id)
            }
        }

        for category in TeaCategory.all {
            XCTAssertTrue(teas.contains { $0.categories.contains(category.name) }, category.name)
        }
    }

    func testRepositorySearchCoversNamesIngredientsHealthTopicsAndGuides() {
        let search = TeaSearchService(teas: teas)

        for query in ["洛神花", "菊花", "睡眠", "血脂", "提神", "痛风", "血压", "国家卫生健康委"] {
            XCTAssertFalse(search.search(query).isEmpty, "Expected search results for: \(query)")
        }

        XCTAssertTrue(search.search("  \n ").isEmpty)
        XCTAssertTrue(search.search("a term that does not exist").isEmpty)
    }

    func testRecommendationsOnlyUseApprovedSeasonalSingleTeas() {
        let service = RecommendationService()
        let fixedDate = chinaDate(year: 2024, month: 9, day: 22, hour: 12)
        let term = SolarTerm(
            name: "秋分",
            season: "秋",
            startDate: fixedDate,
            recommendationContext: "温和的秋季饮品场景。"
        )
        let result = service.recommendation(
            for: fixedDate,
            term: term,
            season: "秋",
            allowedTeas: teas
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.tea.type, .single)
        XCTAssertEqual(result?.tea.seasonRecommendable, true)
        XCTAssertTrue(result?.reason.contains("秋分") == true)
        XCTAssertTrue(result?.reason.contains("秋季") == true)

        let compoundOnly = teas.filter { $0.type == .compound }
        XCTAssertNil(service.recommendation(
            for: fixedDate,
            term: term,
            season: "秋",
            allowedTeas: compoundOnly
        ))
    }

    func testSolarTermSequenceCoversAllTwentyFourTermsInChinaTime() {
        let service = SolarTermService()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        let firstDay = chinaDate(year: 2024, month: 1, day: 1, hour: 12)
        let expectedTransitions = [
            "冬至", "小寒", "大寒", "立春", "雨水", "惊蛰", "春分", "清明", "谷雨",
            "立夏", "小满", "芒种", "夏至", "小暑", "大暑", "立秋", "处暑", "白露",
            "秋分", "寒露", "霜降", "立冬", "小雪", "大雪", "冬至"
        ]

        var actualTransitions: [String] = []
        for offset in 0..<366 {
            let date = calendar.date(byAdding: .day, value: offset, to: firstDay)!
            let term = service.current(for: date)
            XCTAssertEqual(term.season, expectedSeason(for: term.name), "Unexpected season on \(date)")
            if actualTransitions.last != term.name {
                actualTransitions.append(term.name)
            }
        }

        XCTAssertEqual(actualTransitions, expectedTransitions)
    }

    private func expectedSeason(for termName: String) -> String {
        let spring = Set(["立春", "雨水", "惊蛰", "春分", "清明", "谷雨"])
        let summer = Set(["立夏", "小满", "芒种", "夏至", "小暑", "大暑"])
        let autumn = Set(["立秋", "处暑", "白露", "秋分", "寒露", "霜降"])
        if spring.contains(termName) { return "春" }
        if summer.contains(termName) { return "夏" }
        if autumn.contains(termName) { return "秋" }
        return "冬"
    }

    private func chinaDate(year: Int, month: Int, day: Int, hour: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}

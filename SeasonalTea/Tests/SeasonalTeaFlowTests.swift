import XCTest

@MainActor
final class SeasonalTeaFlowTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testRecommendationDetailOpensFromHome() {
        XCTAssertTrue(app.staticTexts["今日推荐"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["为什么今天推荐？"].exists)

        tapElement("home.recommendedTeaDetail")
        XCTAssertTrue(app.staticTexts["原料"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["来源"].exists)
    }

    func testHomeCategoryAndTeaDetailFlow() {
        XCTAssertTrue(app.staticTexts["今日推荐"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["为什么今天推荐？"].exists)
        XCTAssertTrue(app.staticTexts["今日推荐养生茶"].exists)

        tapElement("home.enterLibrary")
        XCTAssertTrue(app.navigationBars["养生茶库"].waitForExistence(timeout: 5))

        tapElement("library.category.血压管理")
        XCTAssertTrue(app.navigationBars["血压管理"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "国家卫生健康委食养指南" )).firstMatch.exists)

        tapElement("teaCard.hibiscus")
        XCTAssertTrue(app.staticTexts["原料"].waitForExistence(timeout: 5), "Detail page was not opened.\n\(app.debugDescription)")

        for section in ["原料", "功效 / 食养定位", "配方与制作", "证据说明", "注意事项", "来源"] {
            XCTAssertTrue(app.staticTexts[section].exists, "Missing detail section: \(section)")
        }
        XCTAssertTrue(app.buttons["分享茶饮资料"].exists)

        let sourceLink = app.buttons["tea.sourceLink"]
        for _ in 0..<8 where !sourceLink.isHittable {
            app.scrollViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(sourceLink.isHittable, "Source link was not reachable.\n\(app.debugDescription)")
    }

    func testSearchFindsTeaByIngredient() {
        let searchField = openLibrarySearch()
        searchField.tap()
        searchField.typeText("NCCIH")

        XCTAssertTrue(app.staticTexts["绿茶"].waitForExistence(timeout: 5))
    }

    func testSearchShowsEmptyStateForUnknownQuery() {
        let searchField = openLibrarySearch()
        searchField.tap()
        searchField.typeText("CodexSearchNoMatch")

        XCTAssertTrue(app.staticTexts["暂时没有找到相关茶饮"].waitForExistence(timeout: 5))
    }

    func testSourceLinkOpensSafari() {
        tapElement("home.enterLibrary")
        tapElement("library.category.血压管理")
        tapElement("teaCard.hibiscus")
        XCTAssertTrue(app.staticTexts["原料"].waitForExistence(timeout: 5), "Detail page was not opened.\n\(app.debugDescription)")

        let sourceLink = app.buttons["tea.sourceLink"]
        for _ in 0..<8 where !sourceLink.isHittable {
            app.scrollViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(sourceLink.isHittable, "Source link was not reachable.\n\(app.debugDescription)")
        sourceLink.tap()

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        XCTAssertTrue(safari.waitForExistence(timeout: 15), "The source link should open Safari.")
    }

    private func openLibrarySearch() -> XCUIElement {
        tapElement("home.enterLibrary")
        XCTAssertTrue(app.navigationBars["养生茶库"].waitForExistence(timeout: 5))

        let searchField = app.textFields["library.searchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        return searchField
    }

    private func tapElement(_ identifier: String) {
        let element = app.descendants(matching: .any).matching(identifier: identifier).firstMatch
        XCTAssertTrue(element.waitForExistence(timeout: 5), "Missing element: \(identifier)")
        element.tap()
    }
}

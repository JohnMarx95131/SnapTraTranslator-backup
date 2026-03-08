import XCTest
@testable import SnapTra_Translator

final class LookupDirectionTests: XCTestCase {
    func testResolvesEnglishTokenToEnglishToChinese() {
        let result = LookupDirectionResolver.resolveDirection(
            for: "hello",
            defaultDirection: .englishToChinese,
            lastResolvedDirection: nil
        )

        XCTAssertEqual(result, .englishToChinese)
    }

    func testResolvesChineseTokenToChineseToEnglish() {
        let result = LookupDirectionResolver.resolveDirection(
            for: "你好",
            defaultDirection: .englishToChinese,
            lastResolvedDirection: nil
        )

        XCTAssertEqual(result, .chineseToEnglish)
    }

    func testFallsBackToLastResolvedDirectionForAmbiguousToken() {
        let result = LookupDirectionResolver.resolveDirection(
            for: "2026",
            defaultDirection: .englishToChinese,
            lastResolvedDirection: .chineseToEnglish
        )

        XCTAssertEqual(result, .chineseToEnglish)
    }
}

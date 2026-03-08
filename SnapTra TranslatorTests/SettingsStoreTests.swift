import XCTest
@testable import SnapTra_Translator

@MainActor
final class LookupConfigurationResolverTests: XCTestCase {
    func testFixedDirectionKeepsConfiguredLanguagePair() {
        let result = LookupConfigurationResolver.resolve(
            token: "hello",
            translationMode: .fixedDirection,
            sourceLanguageIdentifier: "en",
            targetLanguageIdentifier: "ja",
            chineseIdentifier: "zh-Hans",
            defaultDirection: .englishToChinese,
            lastResolvedDirection: .chineseToEnglish
        )

        XCTAssertNil(result.direction)
        XCTAssertEqual(result.pair, .fixed(sourceIdentifier: "en", targetIdentifier: "ja"))
    }

    func testAutoModeResolvesChineseTokenToChineseToEnglishPair() {
        let result = LookupConfigurationResolver.resolve(
            token: "你好",
            translationMode: .autoMutualChineseEnglish,
            sourceLanguageIdentifier: "en",
            targetLanguageIdentifier: "ja",
            chineseIdentifier: "zh-Hant",
            defaultDirection: .englishToChinese,
            lastResolvedDirection: nil
        )

        XCTAssertEqual(result.direction, .chineseToEnglish)
        XCTAssertEqual(result.pair, .automatic(direction: .chineseToEnglish, chineseIdentifier: "zh-Hant"))
    }

    func testAutoModeFallsBackToDefaultDirectionForAmbiguousToken() {
        let result = LookupConfigurationResolver.resolve(
            token: "2026",
            translationMode: .autoMutualChineseEnglish,
            sourceLanguageIdentifier: "en",
            targetLanguageIdentifier: "ja",
            chineseIdentifier: "zh-Hans",
            defaultDirection: .chineseToEnglish,
            lastResolvedDirection: nil
        )

        XCTAssertEqual(result.direction, .chineseToEnglish)
        XCTAssertEqual(result.pair, .automatic(direction: .chineseToEnglish, chineseIdentifier: "zh-Hans"))
    }
}

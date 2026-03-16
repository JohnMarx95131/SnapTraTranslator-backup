import XCTest
@testable import SnapTra_Translator

@MainActor
final class LookupLanguagePairTests: XCTestCase {
    func testFixedLanguagePairPreservesIdentifiers() {
        let pair = LookupLanguagePair.fixed(sourceIdentifier: "en", targetIdentifier: "ja")

        XCTAssertEqual(pair.sourceIdentifier, "en")
        XCTAssertEqual(pair.targetIdentifier, "ja")
    }

    func testSameLanguageDetection() {
        let pair = LookupLanguagePair.fixed(sourceIdentifier: "en", targetIdentifier: "en")
        XCTAssertTrue(pair.isSameLanguage)
    }

    func testDifferentLanguageDetection() {
        let pair = LookupLanguagePair.fixed(sourceIdentifier: "en", targetIdentifier: "zh-Hans")
        XCTAssertFalse(pair.isSameLanguage)
    }
}

@MainActor
final class SettingsStoreMigrationTests: XCTestCase {
    func testDefaultDictionarySources() {
        let sources = SettingsStore.defaultDictionarySources(ecdictInstalled: false)

        XCTAssertEqual(
            sources.map(\.type),
            [.ecdict, .system]
        )
        XCTAssertTrue(sources.contains { $0.type == .system && $0.isEnabled })
    }

    func testMigrationRemovesHiddenProviders() {
        let existing: [DictionarySource] = [
            DictionarySource(id: UUID(), name: "System Dictionary", type: .system, isEnabled: true),
            DictionarySource(id: UUID(), name: "Advanced Dictionary", type: .ecdict, isEnabled: true),
            DictionarySource(id: UUID(), name: "Google Translate", type: .google, isEnabled: false),
            DictionarySource(id: UUID(), name: "Bing Dictionary", type: .bing, isEnabled: true),
        ]
        let migrated = SettingsStore.migrateDictionarySources(existing)

        XCTAssertEqual(
            migrated.map(\.type),
            [.system, .ecdict]
        )
        XCTAssertEqual(
            migrated.filter(\.isEnabled).map(\.type),
            [.system, .ecdict]
        )
    }
}

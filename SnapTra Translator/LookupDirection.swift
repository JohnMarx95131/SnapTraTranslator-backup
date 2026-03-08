import Foundation

enum LookupDirection: String, CaseIterable, Identifiable {
    case englishToChinese
    case chineseToEnglish

    var id: String { rawValue }

    var title: String {
        switch self {
        case .englishToChinese:
            return L("English -> Chinese")
        case .chineseToEnglish:
            return L("Chinese -> English")
        }
    }

    func sourceLanguageIdentifier(chineseIdentifier: String) -> String {
        switch self {
        case .englishToChinese:
            return "en"
        case .chineseToEnglish:
            return chineseIdentifier
        }
    }

    func targetLanguageIdentifier(chineseIdentifier: String) -> String {
        switch self {
        case .englishToChinese:
            return chineseIdentifier
        case .chineseToEnglish:
            return "en"
        }
    }
}

struct LookupLanguagePair: Equatable {
    let sourceIdentifier: String
    let targetIdentifier: String

    var key: String {
        "\(sourceIdentifier)->\(targetIdentifier)"
    }

    var sourceLanguage: Locale.Language {
        Locale.Language(identifier: sourceIdentifier)
    }

    var targetLanguage: Locale.Language {
        Locale.Language(identifier: targetIdentifier)
    }

    var targetIsEnglish: Bool {
        targetLanguage.minimalIdentifier == "en"
    }

    var targetIsChinese: Bool {
        targetLanguage.minimalIdentifier == "zh"
    }

    var isSameLanguage: Bool {
        sourceLanguage.minimalIdentifier == targetLanguage.minimalIdentifier
    }

    static func fixed(sourceIdentifier: String, targetIdentifier: String) -> LookupLanguagePair {
        LookupLanguagePair(
            sourceIdentifier: sourceIdentifier,
            targetIdentifier: targetIdentifier
        )
    }

    static func automatic(
        direction: LookupDirection,
        chineseIdentifier: String
    ) -> LookupLanguagePair {
        LookupLanguagePair(
            sourceIdentifier: direction.sourceLanguageIdentifier(chineseIdentifier: chineseIdentifier),
            targetIdentifier: direction.targetLanguageIdentifier(chineseIdentifier: chineseIdentifier)
        )
    }
}

struct ResolvedLookupConfiguration: Equatable {
    let pair: LookupLanguagePair
    let direction: LookupDirection?
}

enum LookupDirectionResolver {
    private static let englishLetterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

    static func resolveDirection(
        for token: String,
        defaultDirection: LookupDirection,
        lastResolvedDirection: LookupDirection?
    ) -> LookupDirection {
        let script = classify(token)

        switch script {
        case .english:
            return .englishToChinese
        case .chinese:
            return .chineseToEnglish
        case .mixed, .unknown:
            return lastResolvedDirection ?? defaultDirection
        }
    }

    static func classify(_ token: String) -> OCRTokenScript {
        var hanCount = 0
        var englishCount = 0

        for scalar in token.unicodeScalars {
            if scalar.properties.isIdeographic {
                hanCount += 1
            } else if englishLetterSet.contains(scalar) {
                englishCount += 1
            }
        }

        if hanCount > 0 && englishCount == 0 {
            return .chinese
        }

        if englishCount > 0 && hanCount == 0 {
            return .english
        }

        if hanCount > 0 && englishCount > 0 {
            return .mixed
        }

        return .unknown
    }
}

enum LookupConfigurationResolver {
    static func resolve(
        token: String,
        translationMode: TranslationMode,
        sourceLanguageIdentifier: String,
        targetLanguageIdentifier: String,
        chineseIdentifier: String,
        defaultDirection: LookupDirection,
        lastResolvedDirection: LookupDirection?
    ) -> ResolvedLookupConfiguration {
        switch translationMode {
        case .fixedDirection:
            return ResolvedLookupConfiguration(
                pair: .fixed(
                    sourceIdentifier: sourceLanguageIdentifier,
                    targetIdentifier: targetLanguageIdentifier
                ),
                direction: nil
            )
        case .autoMutualChineseEnglish:
            let direction = LookupDirectionResolver.resolveDirection(
                for: token,
                defaultDirection: defaultDirection,
                lastResolvedDirection: lastResolvedDirection
            )
            return ResolvedLookupConfiguration(
                pair: .automatic(direction: direction, chineseIdentifier: chineseIdentifier),
                direction: direction
            )
        }
    }
}

enum OCRTokenScript: Equatable {
    case chinese
    case english
    case mixed
    case unknown
}

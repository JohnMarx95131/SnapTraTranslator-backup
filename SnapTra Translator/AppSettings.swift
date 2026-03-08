import Foundation

enum SingleKey: String, CaseIterable, Identifiable {
    case leftShift
    case leftControl
    case leftOption
    case leftCommand
    case rightShift
    case rightControl
    case rightOption
    case rightCommand
    case fn

    var id: String { rawValue }

    var title: String {
        switch self {
        case .leftShift:
            return String(localized: "Left Shift")
        case .leftControl:
            return String(localized: "Left Control")
        case .leftOption:
            return String(localized: "Left Option")
        case .leftCommand:
            return String(localized: "Left Command")
        case .rightShift:
            return String(localized: "Right Shift")
        case .rightControl:
            return String(localized: "Right Control")
        case .rightOption:
            return String(localized: "Right Option")
        case .rightCommand:
            return String(localized: "Right Command")
        case .fn:
            return "Fn"
        }
    }
}

enum TTSProvider: String, CaseIterable, Identifiable {
    case apple = "apple"
    case youdao = "youdao"
    case bing = "bing"
    case edge = "edge"
    case google = "google"
    case baidu = "baidu"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .apple:
            return String(localized: "Apple")
        case .youdao:
            return String(localized: "Youdao")
        case .bing:
            return String(localized: "Bing")
        case .edge:
            return String(localized: "Edge")
        case .google:
            return String(localized: "Google")
        case .baidu:
            return String(localized: "Baidu")
        }
    }

    var requiresNetwork: Bool {
        self != .apple
    }

    var description: String {
        switch self {
        case .apple:
            return String(localized: "System built-in, works offline")
        case .youdao:
            return String(localized: "No token required, supports UK/US accent")
        case .bing:
            return String(localized: "Best quality, requires token")
        case .edge:
            return String(localized: "Best quality, WebSocket based")
        case .google:
            return String(localized: "Good quality, requires signature")
        case .baidu:
            return String(localized: "No token required, supports UK/US accent")
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case english = "en"
    case chineseSimplified = "zh-Hans"
    case chineseTraditional = "zh-Hant"
    case japanese = "ja"
    case korean = "ko"
    case french = "fr"
    case german = "de"
    case spanish = "es"
    case italian = "it"
    case portuguese = "pt"
    case russian = "ru"
    case arabic = "ar"
    case thai = "th"
    case vietnamese = "vi"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:
            return String(localized: "System Language")
        case .english:
            return "English"
        case .chineseSimplified:
            return "简体中文"
        case .chineseTraditional:
            return "繁體中文"
        case .japanese:
            return "日本語"
        case .korean:
            return "한국어"
        case .french:
            return "Français"
        case .german:
            return "Deutsch"
        case .spanish:
            return "Español"
        case .italian:
            return "Italiano"
        case .portuguese:
            return "Português"
        case .russian:
            return "Русский"
        case .arabic:
            return "العربية"
        case .thai:
            return "ไทย"
        case .vietnamese:
            return "Tiếng Việt"
        }
    }

    var localeIdentifier: String? {
        switch self {
        case .system:
            return nil
        default:
            return rawValue
        }
    }
}

enum AppSettingKey {
    static let playPronunciation = "playPronunciation"
    static let launchAtLogin = "launchAtLogin"
    static let singleKey = "singleKey"
    static let sourceLanguage = "sourceLanguage"
    static let targetLanguage = "targetLanguage"
    static let debugShowOcrRegion = "debugShowOcrRegion"
    static let continuousTranslation = "continuousTranslation"
    static let lastScreenRecordingStatus = "lastScreenRecordingStatus"
    static let ttsProvider = "ttsProvider"
    static let appLanguage = "appLanguage"
}

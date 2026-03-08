import Combine
import Foundation
import SwiftUI

final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: AppLanguage = .system
    
    private init() {
        // Load saved language preference
        let savedLanguage = UserDefaults.standard.string(forKey: AppSettingKey.appLanguage)
        if let saved = savedLanguage,
           let language = AppLanguage(rawValue: saved) {
            currentLanguage = language
            applyLanguage(language)
        }
    }
    
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        applyLanguage(language)
        
        // Post notification for views to update
        NotificationCenter.default.post(name: .languageChanged, object: nil)
    }
    
    private func applyLanguage(_ language: AppLanguage) {
        guard let identifier = language.localeIdentifier else {
            // Reset to system default
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
            return
        }
        
        // Set the language preference
        UserDefaults.standard.set([identifier], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    /// Get localized string with current language context
    func localizedString(_ key: String) -> String {
        if let identifier = currentLanguage.localeIdentifier {
            guard let path = Bundle.main.path(forResource: identifier, ofType: "lproj"),
                  let bundle = Bundle(path: path) else {
                return NSLocalizedString(key, comment: "")
            }
            return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
        }
        return NSLocalizedString(key, comment: "")
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

// MARK: - SwiftUI Helper

struct LocalizedViewModifier: ViewModifier {
    @StateObject private var localizationManager = LocalizationManager.shared
    
    func body(content: Content) -> some View {
        content
            .id(localizationManager.currentLanguage.rawValue)
    }
}

extension View {
    func localized() -> some View {
        self.modifier(LocalizedViewModifier())
    }
}

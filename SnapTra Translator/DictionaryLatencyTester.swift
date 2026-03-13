//
//  DictionaryLatencyTester.swift
//  SnapTra Translator
//
//  Latency testing for online dictionary services.
//

import Combine
import Foundation

/// Manages latency testing for online dictionary sources.
@MainActor
final class DictionaryLatencyTester: ObservableObject {
    enum LatencyResult: Equatable {
        case pending
        case testing
        case success(TimeInterval)  // milliseconds
        case failed
        case local  // For offline sources
    }

    @Published var latencies: [DictionarySource.SourceType: LatencyResult] = [:]
    @Published var isTesting = false

    private let session: URLSession

    init(session: URLSession? = nil) {
        self.session = session ?? DictionaryLatencyTester.makeSession()
    }

    /// Test all online dictionary sources.
    func testAll() async {
        // No online dictionary sources to test after removing Free Dictionary
    }

    /// Test latency for a specific dictionary source.
    private func testLatency(for type: DictionarySource.SourceType) async -> LatencyResult {
        switch type {
        case .system, .ecdict, .google, .bing, .youdao, .deepl:
            return .local
        }
    }

    private static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 8
        configuration.timeoutIntervalForResource = 12
        return URLSession(configuration: configuration)
    }
}

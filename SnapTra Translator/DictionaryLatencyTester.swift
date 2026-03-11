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
        guard !isTesting else { return }
        isTesting = true
        defer { isTesting = false }

        let onlineTypes: [DictionarySource.SourceType] = [.freeDict]

        // Reset to testing state
        for type in onlineTypes {
            latencies[type] = .testing
        }

        // Test in parallel
        await withTaskGroup(of: (DictionarySource.SourceType, LatencyResult).self) { group in
            for type in onlineTypes {
                group.addTask { [weak self] in
                    guard let self = self else { return (type, .failed) }
                    let result = await self.testLatency(for: type)
                    return (type, result)
                }
            }

            for await (type, result) in group {
                self.latencies[type] = result
            }
        }
    }

    /// Test latency for a specific dictionary source.
    private func testLatency(for type: DictionarySource.SourceType) async -> LatencyResult {
        switch type {
        case .freeDict:
            return await testFreeDictionary()
        case .system, .ecdict, .google, .bing, .youdao, .deepl:
            return .local
        }
    }

    private func testFreeDictionary() async -> LatencyResult {
        let testWord = "hello"
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(testWord)") else {
            return .failed
        }

        let startTime = Date()

        do {
            let (_, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                return .failed
            }

            let elapsed = Date().timeIntervalSince(startTime) * 1000  // Convert to ms
            return .success(elapsed)

        } catch {
            return .failed
        }
    }

    private static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 8
        configuration.timeoutIntervalForResource = 12
        return URLSession(configuration: configuration)
    }
}

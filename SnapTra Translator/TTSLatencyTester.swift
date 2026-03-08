import Combine
import Foundation

@MainActor
final class TTSLatencyTester: ObservableObject {
    @Published var latencies: [TTSProvider: LatencyResult] = [:]
    @Published var isTesting = false
    
    private let testText = "hello"
    private let timeout: TimeInterval = 5.0
    
    enum LatencyResult: Equatable {
        case pending
        case testing
        case success(TimeInterval)
        case failed
        case offline
    }
    
    private let ttsFactory = TTSServiceFactory()
    
    init() {
        for provider in TTSProvider.allCases {
            latencies[provider] = provider == .apple ? .offline : .pending
        }
    }
    
    func testAllProviders() async {
        guard !isTesting else { return }
        isTesting = true
        
        for provider in TTSProvider.allCases where provider != .apple {
            latencies[provider] = .testing
        }
        
        await withTaskGroup(of: (TTSProvider, LatencyResult).self) { group in
            for provider in TTSProvider.allCases where provider != .apple {
                group.addTask {
                    let result = await self.testProvider(provider)
                    return (provider, result)
                }
            }
            
            for await (provider, result) in group {
                latencies[provider] = result
            }
        }
        
        isTesting = false
    }
    
    func testProvider(_ provider: TTSProvider) async -> LatencyResult {
        guard provider != .apple else { return .offline }
        
        do {
            let start = Date()
            _ = try await ttsFactory.fetchAudio(
                text: testText,
                language: "en",
                provider: provider,
                useAmericanAccent: true
            )
            let elapsed = Date().timeIntervalSince(start) * 1000
            return .success(elapsed)
        } catch {
            return .failed
        }
    }
}
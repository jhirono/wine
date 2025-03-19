import Foundation

struct Configuration {
    // MARK: - API Keys
    
    static var openAIAPIKey: String {
        return value(for: "OPENAI_API_KEY") ?? ""
    }
    
    // MARK: - Private Helper Methods
    
    private static func value(for key: String) -> String? {
        // First try loading from Config.plist (excluded from git)
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let value = dict[key] as? String {
            return value
        }
        
        // Then try loading from environment
        return ProcessInfo.processInfo.environment[key]
    }
} 
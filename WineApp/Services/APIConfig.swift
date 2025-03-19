import Foundation
import Security

// Internal Configuration implementation for APIConfig
private struct ConfigurationImpl {
    static var openAIAPIKey: String {
        return value(for: "OPENAI_API_KEY") ?? ""
    }
    
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

struct APIConfig {
    // OpenAI API endpoint
    static let openAIEndpoint = "https://api.openai.com/v1/chat/completions"
    
    // GPT model to use
    static let openAIModel = "gpt-4o"
    
    // Secure access to OpenAI API key
    static var openAIAPIKey: String {
        if let key = retrieveKeyFromKeychain() {
            return key
        }
        
        // Try to get key from Configuration
        let configKey = ConfigurationImpl.openAIAPIKey
        if !configKey.isEmpty {
            // Store key in keychain for future use
            storeKeyInKeychain(configKey)
            return configKey
        }
        
        // No key found
        print("ERROR: No OpenAI API key found. Please add it to Config.plist")
        return ""
    }
    
    // MARK: - Private Methods
    
    private static func storeKeyInKeychain(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "OpenAIAPIKey",
            kSecAttrService as String: "WineApp",
            kSecValueData as String: key.data(using: .utf8)!
        ]
        
        // Delete any existing key before storing a new one
        SecItemDelete(query as CFDictionary)
        
        // Add the new key
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error storing API key in keychain: \(status)")
        }
    }
    
    private static func retrieveKeyFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "OpenAIAPIKey",
            kSecAttrService as String: "WineApp",
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let retrievedData = dataTypeRef as? Data {
            return String(data: retrievedData, encoding: .utf8)
        } else {
            return nil
        }
    }
} 

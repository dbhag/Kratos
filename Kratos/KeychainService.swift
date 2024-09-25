import Security
import Foundation
import SwiftUI


class KeychainService {
    static func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ] as [String : Any]
        
        SecItemDelete(query as CFDictionary) // Delete any existing key
        return SecItemAdd(query as CFDictionary, nil) // Save the new key
    }

    static func load(key: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne
        ] as [String : Any]

        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }

    static func delete(key: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as [String : Any]

        SecItemDelete(query as CFDictionary)
    }
}

// A function to set up the API key in the Keychain only once
func setupAPIKeyIfNeeded() {
    let apiKey = "AIzaSyD_8uPebiTIcdo18gMdOZ0btqXeJpWDPG8"

    // Check if the API key has already been stored in Keychain
    let isAPIKeySaved = UserDefaults.standard.bool(forKey: "isAPIKeySaved")

    if !isAPIKeySaved {
        // Store the API key in Keychain
        if let apiKeyData = apiKey.data(using: .utf8) {
            let status = KeychainService.save(key: "API_KEY", data: apiKeyData)
            if status == errSecSuccess {
                // Mark that the API key has been saved so we don't save it again
                UserDefaults.standard.set(true, forKey: "isAPIKeySaved")
                print("API key saved successfully")
            } else {
                print("Failed to save API key: \(status)")
            }
        }
    }
}


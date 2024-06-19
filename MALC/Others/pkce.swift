import Foundation
import CryptoKit


/// Code taken from https://gist.github.com/travisnewby/b030cf862862c0c55777e3db50eaccf8
///
/// An easy-to-use implementation of the client side of the [PKCE standard](https://datatracker.ietf.org/doc/html/rfc7636).
///
struct PKCE {
    
    typealias PKCECode = String
    
    ///
    /// Generates a random code verifier (as defined in [Seciton 4.1 of the PKCE standard](https://datatracker.ietf.org/doc/html/rfc7636#section-4.1)).
    ///
    /// This method first attempts to use CryptoKit to generate random bytes. If it fails to generate those random bytes, it falls back on a generic
    /// Base64 random string generator.
    ///
    static func generateCodeVerifier() -> PKCECode {
        
        do {
            
            let rando = try PKCE.generateCryptographicallySecureRandomOctets(count: 32)
            return Data(bytes: rando, count: rando.count).base64URLEncodedString
            
        } catch {
            
            return generateBase64RandomString(ofLength: 43)
        }
    }
    
    private static func generateCryptographicallySecureRandomOctets(count: Int) throws -> [UInt8] {
        
        var octets = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, octets.count, &octets)
        
        if status == errSecSuccess {
            
            return octets
            
        } else {
            
            throw PKCEError.failedToGenerateRandomOctets
        }
    }
    
    private static func generateBase64RandomString(ofLength length: UInt8) -> PKCECode {
        
        let base64 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in base64.randomElement()! })
    }
    
    enum PKCEError: Error {
        
        case failedToGenerateRandomOctets
        case improperlyFormattedVerifier
    }
}

extension Data {
    
    ///
    /// Returns a Base64 URL-encoded string _without_ padding.
    ///
    /// This string is compatible with the PKCE Code generation process, and uses the algorithm as defined in the [PKCE standard](https://datatracker.ietf.org/doc/html/rfc7636#appendix-A).
    ///
    var base64URLEncodedString: String {
    
        base64EncodedString()
            .replacingOccurrences(of: "=", with: "") // Remove any trailing '='s
            .replacingOccurrences(of: "+", with: "-") // 62nd char of encoding
            .replacingOccurrences(of: "/", with: "_") // 63rd char of encoding
            .trimmingCharacters(in: .whitespaces)
    }
}

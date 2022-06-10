//
//  HMAC.swift
//  sYg
//
//  Created by Jack Wang on 6/7/22.
//

import Foundation
import CryptoKit

class Crypto {
    
    // What type is the message
    static func generateHMAC(keyString: String) -> (hmac: String, message: String) {
        let key = SymmetricKey(data: Data(keyString.utf8))
        let message = Crypto.randomString(length: 18)
        let signature = HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: key)
        let signatureString = Data(signature).map { String(format: "%02hhx", $0) }.joined()
        return (signatureString, message)
    }
    
    static func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

//
//  KeychainApp.swift
//  Keychain
//
//  Created by Jamil Nawaz on 14/02/2023.
//

import SwiftUI

@main
struct KeychainApp: App {
    
    let tag = "com.example.keys.mykey".data(using: .utf8)!
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { URL in
                    print(URL)
                    
                    DispatchQueue.global(qos: .background).async {
                        do {
                            let dataOfP13 = try Data(contentsOf: URL) as CFData
                            //                            print(dataOfP13)
                            
                            let pkcs12Options = [
                                kSecImportExportPassphrase: "password"
                            ] as CFDictionary
                            
                            var items: CFArray?
                            
                            let decodeSuccess = SecPKCS12Import(dataOfP13, pkcs12Options, &items)
                            guard decodeSuccess == errSecSuccess else { throw KeychainError.pkcs12decodingerror }
                            
                            //                            print(items)
                            
                            let identityDictionaries = items as! [[String: Any]]
                            
                            let certChain = identityDictionaries[0][kSecImportItemCertChain as String] as! SecCertificate
                            
                            let key = identityDictionaries[0][kSecImportItemIdentity as String] as! SecIdentity
                            
                            
                            if keyInKeychain() == nil {
                                print("key not in keychain")
                                addKeyToKeyChain(key)
                            } else {
                                print("key in keychain")
                            }
                            
                            if certInKeyChain() == nil {
                                print("cert not in key chain")
                                addCertToKeyChain(key)
                            } else {
                                print("cert in keychain")
                            }
                        }
                        catch {
                            print("Error: \(error)")
                        }
                    }
                }
        }
    }
    
    func keyInKeychain() -> SecKey? {
        do {
            let getquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                           kSecAttrApplicationTag as String: tag,
                                           kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                           kSecReturnRef as String: true]
            var item: CFTypeRef?
            let status = SecItemCopyMatching(getquery as CFDictionary, &item)
            guard status == errSecSuccess else { throw KeychainError.keyNotFound }
            let key = item as! SecKey
            return key
        } catch {
            return nil
        }
    }
    
    func addKeyToKeyChain(_ key: SecIdentity) {
        
        do {
            
            var privateKey: SecKey?
            let pkstatus = SecIdentityCopyPrivateKey(key, &privateKey)
            guard pkstatus == errSecSuccess else { throw KeychainError.extractingPrivateKey }
            
            
            let addquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                           kSecAttrApplicationTag as String: tag,
                                           kSecValueRef as String: privateKey!]
            let status = SecItemAdd(addquery as CFDictionary, nil)
            guard status == errSecSuccess else { throw KeychainError.failedToAddKey }
            
            print("key added to keychain")
        } catch {
            print("Error \(error)")
        }
        
    }

    func certInKeyChain() -> SecCertificate? {
        do {
            let getquery: [String: Any] = [kSecClass as String: kSecClassCertificate,
                                           kSecAttrLabel as String: "My Certificate",
                                           kSecReturnRef as String: kCFBooleanTrue]
            
            var item: CFTypeRef?
            let status = SecItemCopyMatching(getquery as CFDictionary, &item)
            guard status == errSecSuccess else { throw KeychainError.retrievingCert }
            let certificate = item as! SecCertificate
            
            return certificate
        } catch {
            return nil
        }
        
    }

    func addCertToKeyChain(_ cert: SecIdentity) {
        
        do {
            
            var certificate: SecCertificate?
            let certstatus = SecIdentityCopyCertificate(cert, &certificate)
            guard certstatus == errSecSuccess else { throw KeychainError.extractingCert }
            
            let addquery: [String: Any] = [kSecClass as String: kSecClassCertificate,
                                           kSecValueRef as String: certificate!,
                                           kSecAttrLabel as String: "My Certificate"]
            
            let status = SecItemAdd(addquery as CFDictionary, nil)
            guard status == errSecSuccess else { throw KeychainError.failedToAddCert }
            print("cert added to keychain")
        } catch {
            print("Error \(error)")
        }
        
        
    }

    
}




enum KeychainError: Error {
    case pkcs12decodingerror
    case keyNotFound
    case failedToAddKey
    case extractingPrivateKey
    case extractingCert
    case failedToAddCert
    case retrievingCert
}

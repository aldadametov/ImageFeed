//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Алишер Дадаметов on 18.07.2023.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let tokenKey = "OAuth2AccessToken"
    
    var token: String? {
        get {
            let token = KeychainWrapper.standard.string(forKey: tokenKey)
            guard let token = token else { return nil }
            return token
        }
        set {
            guard let newValue = newValue else { return }
            let isSuccess = KeychainWrapper.standard.set(newValue, forKey: tokenKey)
            guard isSuccess else {
                print("Ошибка записи")
                return
            }
        }
    }
}

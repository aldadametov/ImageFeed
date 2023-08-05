//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Алишер Дадаметов on 18.07.2023.
//

import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let defaults = UserDefaults.standard
    private let tokenKey = "OAuth2AccessToken"
    
    var token: String? {
        get {
            return defaults.string(forKey: tokenKey)
        }
        set {
            defaults.set(newValue, forKey: tokenKey)
        }
    }
}

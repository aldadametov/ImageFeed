//
//  Constants.swift
//  ImageFeed
//
//  Created by Алишер Дадаметов on 10.07.2023.
//

import Foundation

let AccessKey = "Xj5TzB02YbhGYowHtiwmMnGd_T7Q92UnwEVYjBJYFBg"
let SecretKey = "c5OQH4liaASAHf5sk2kXYKaAPDTO-nRHwsFVhXAUamM"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"

let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
let DefaultBaseURL = URL(string: "https://api.unsplash.com")!

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
            return AuthConfiguration(accessKey: AccessKey,
                                     secretKey: SecretKey,
                                     redirectURI: RedirectURI,
                                     accessScope: AccessScope,
                                     authURLString: UnsplashAuthorizeURLString,
                                     defaultBaseURL: DefaultBaseURL)
        }
}

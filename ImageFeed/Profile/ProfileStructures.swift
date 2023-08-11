//
//  ProfileStructures.swift
//  ImageFeed
//
//  Created by Алишер Дадаметов on 02.08.2023.
//

import Foundation

struct ProfileResult: Codable {
    let userLogin: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    
    private enum CodingKeys: String, CodingKey {
        case userLogin = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct UserResult: Codable {
    let profileImage: [String:String]
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let profileImage: [String:String]
    
    init(decodedData: UserResult) {
        self.profileImage = decodedData.profileImage
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

extension Profile {
    init(result profile: ProfileResult) {
        self.init(
            username: profile.userLogin,
            name: "\(profile.firstName ?? "") \(profile.lastName ?? "")",
            loginName: "@\(profile.userLogin)",
            bio: profile.bio
        )
    }
}

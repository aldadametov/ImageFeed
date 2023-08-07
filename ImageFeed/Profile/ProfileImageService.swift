//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Алишер Дадаметов on 05.08.2023.
//

import Foundation
import UIKit

final class ProfileImageService {
    static let shared = ProfileImageService()
    private (set) var avatarURL: String?
    private let urlSession = URLSession.shared
    private var currentTask: URLSessionTask?
    private let storageToken = OAuth2TokenStorage()
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        let request = makeRequest(token: storageToken.token!, username: username)
        let task = fetch(for: request) {[weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let decodedObject):
                let profileImage = ProfileImage(decodedData: decodedObject)
                self.avatarURL = profileImage.profileImage["small"]
                if let avatarURL = self.avatarURL, !avatarURL.isEmpty {
                    // Perform actions when avatarURL exists and is not empty
                    print("AvatarURL: \(avatarURL)")
                } else {
                    // Perform actions when avatarURL is nil or empty
                    print("AvatarURL is nil or empty.")
                    // TODO: Perform any additional actions you need
                }
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.DidChangeNotification,
                        object: self,
                        userInfo: ["URL": self.avatarURL ?? ""])
            case .failure(let error):
                completion( .failure(error))
            }
        }
        self.currentTask = task
        task.resume()
    }
    
    private func fetch(
        for request: URLRequest,
        completion: @escaping (Result<UserResult, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.objectTask(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<UserResult, Error> in
                Result { try decoder.decode(UserResult.self, from: data) }
            }
            completion(response)
        }
    }
    
    private func makeRequest(token: String, username: String) -> URLRequest {
        guard let url = URL(string: "https://api.unsplash.com" + "/users/" + username) else { fatalError("Error") }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}


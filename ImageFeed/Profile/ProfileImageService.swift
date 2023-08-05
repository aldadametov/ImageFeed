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
        
        guard let request = makeRequest(userName: username) else {return}
        let task = fetch(for: request) {[weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let decodedObject):
                let avatarURL = ProfileImage(decodedData: decodedObject)
                self.avatarURL = avatarURL.profileImage["small"]
                completion(.success(self.avatarURL!))
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
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<UserResult, Error> in
                Result { try decoder.decode(UserResult.self, from: data) }
            }
            completion(response)
        }
    }
    
    private func makeRequest(userName: String) -> URLRequest? {
        URLRequest.makeHTTPRequest(path: "users/\(userName)",
                                   httpMethod: "GET",
                                   baseURL: URL(string: "https://api.unsplash.com/")!)
    }
}


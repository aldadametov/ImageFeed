//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Алишер Дадаметов on 01.08.2023.
//

import Foundation
import UIKit

final class ProfileService {
    static let shared = ProfileService()
    
    private (set) var profile: Profile?
    private var currentTask: URLSessionTask?
    private let urlSession = URLSession.shared
    
    func fetchProfile(_ token: String, completion: @escaping (Result <Profile, Error>) -> Void) {
        
        currentTask?.cancel()
        
        let request = makeRequest(token: token)
        
        currentTask = fetch(for: request) {[weak self] response in
            self?.currentTask = nil
            switch response {
            case .success(let profileResult):
                let profile = Profile(result: profileResult)
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion( .failure(error))
            }
        }
    }
    
    private func fetch(
        for request: URLRequest,
        completion: @escaping (Result<ProfileResult, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.objectTask(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<ProfileResult, Error> in
                Result { try decoder.decode(ProfileResult.self, from: data) }
            }
            completion(response)
        }
    }
    
    
    private func makeRequest(token: String) -> URLRequest {
        guard let url = URL(string: "\(DefaultBaseURL)" + "/me") else { fatalError("Failed to create URL") }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func resetProfile() {
        profile = nil
    }
}

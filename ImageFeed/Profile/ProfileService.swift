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
        
        guard let request = makeFetchProfileRequest(token: token) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
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
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<ProfileResult, Error> in
                Result { try decoder.decode(ProfileResult.self, from: data) }
            }
            completion(response)
        }
    }
    
    
    private func makeFetchProfileRequest(token: String) -> URLRequest? {
        URLRequest.makeHTTPRequest(path: "/me",
                                   httpMethod: "GET",
                                   baseURL: URL(string: "https://api.unsplash.com")!)
    }
}

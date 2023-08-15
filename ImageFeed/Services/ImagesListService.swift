//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Алишер Дадаметов on 13.08.2023.
//

import Foundation
import CoreGraphics

final class ImagesListService {
    static let shared = ImagesListService()
    private (set) var photos: [Photo] = []
    private let storage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private var currentTask: URLSessionTask?
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private var lastLoadedPage: Int?
    
    private func makeRequest(page: Int) -> URLRequest {
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else {
            fatalError("Error creating URL components")
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
        ]

        guard let url = urlComponents.url else {
            fatalError("Error creating URL")
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(storage.token!)", forHTTPHeaderField: "Authorization")
        return request
    }

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)

        guard currentTask == nil else {
            // Закачка уже идет, прерываем выполнение функции
            return
        }

        let nextPage = (lastLoadedPage ?? 0) + 1
        let request = makeRequest(page: nextPage)
        let task = fetch(for: request) { [weak self] (response: Result<[PhotoResult], Error>) in
            guard let self = self else { return }

            // Убираем блокировку, т.к. запрос завершен
            self.currentTask = nil

            switch response {
            case .success(let photoResults):
                let newPhotos = photoResults.map { Photo(from: $0) }
                self.photos.append(contentsOf: newPhotos)

                // Обновляем lastLoadedPage
                self.lastLoadedPage = nextPage

                // Оповещаем об изменениях
                NotificationCenter.default.post(
                    name: ImagesListService.DidChangeNotification,
                    object: self,
                    userInfo: ["photos": self.photos]
                )
            case .failure(let error):
                print("Ошибка при получении фотографий: \(error)")
            }
        }

        // Устанавливаем текущую задачу
        self.currentTask = task
        task.resume()
    }
    
    private func fetch(
        for request: URLRequest,
        completion: @escaping (Result<[PhotoResult], Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.objectTask(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<[PhotoResult], Error> in
                Result { try decoder.decode([PhotoResult].self, from: data) }
            }
            completion(response)
        }
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(storage.token!)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: request) { (_, response, error) in
            if let error = error {
                completion(.failure(.urlSessionError))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if (200..<300).contains(httpResponse.statusCode) {
                    // Обновление состояния "лайка" в массиве photos
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        var photo = self.photos[index]
                        photo.isLiked = !photo.isLiked
                        self.photos[index] = photo
                    }
                    
                    completion(.success(()))
                } else {
                    completion(.failure(.httpStatusCode(httpResponse.statusCode)))
                }
            } else {
                completion(.failure(.unknown))
            }
        }
        
        task.resume()
    }



     
}


struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String

    enum CodingKeys: String, CodingKey {
        case raw = "raw"
        case full = "full"
        case regular = "regular"
        case small = "small"
        case thumb = "thumb"
    }
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case createdAt = "created_at"
        case width = "width"
        case height = "height"
        case description = "description"
        case urls = "urls"
        case likedByUser = "liked_by_user"
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
    
    init(from photoResult: PhotoResult) {
        id = photoResult.id
        size = CGSize(width: photoResult.width, height: photoResult.height)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        createdAt = dateFormatter.date(from: photoResult.createdAt)
        
        welcomeDescription = photoResult.description
        thumbImageURL = photoResult.urls.thumb
        largeImageURL = photoResult.urls.regular
        isLiked = photoResult.likedByUser
    }
}


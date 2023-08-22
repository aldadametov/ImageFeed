//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Алишер Дадаметов on 22.08.2023.
//

import Foundation
import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

class ImagesListPresenter: ImagesListPresenterProtocol {
    private weak var view: ImagesListViewControllerProtocol?
    private let imagesListService: ImagesListServiceProtocol
    private var imagesListServiceObserver: NSObjectProtocol?
    
    init(view: ImagesListViewControllerProtocol,
         imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.view = view
        self.imagesListService = imagesListService
    }
    
    func viewDidLoad() {
        imagesListService.fetchPhotosNextPage()
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateTableViewAnimated()
        }
    }
    
    func updateTableViewAnimated() {
        guard let view = view else { return }
        let oldCount = view.photos.count
        let newCount = imagesListService.photos.count
        if oldCount != newCount {
            view.photos = imagesListService.photos
            let indexPaths = (oldCount..<newCount).map { index in
                IndexPath(row: index, section: 0)
            }
            view.performBatchUpdate(with: indexPaths)
        }
    }
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = view?.indexPath(for: cell) else { return }
        var photo = imagesListService.photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async { // Выполняем изменения UI в главном потоке
                switch result {
                case .success:
                    photo.isLiked = !photo.isLiked
                    cell.setIsLiked(self.imagesListService.photos[indexPath.row].isLiked)
                    UIBlockingProgressHUD.dismiss()
                case .failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    self.view?.showLikeError(error)
                }
            }
        }
    }
}




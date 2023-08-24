//
//  ViewController.swift
//  ImageFeed
//
//  Created by Алишер Дадаметов on 06.06.2023.
//

import UIKit
import Kingfisher
import ProgressHUD

protocol ImagesListViewControllerProtocol: AnyObject {
    var photos: [Photo] { get set }
    func performBatchUpdate(with indexPaths: [IndexPath])
    func indexPath(for cell: ImagesListCell) -> IndexPath?
    func showLikeError(_ error: Error)
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    
    @IBOutlet private var tableView: UITableView!
    private let imagesListService = ImagesListService.shared
    internal var photos: [Photo] = []
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    var presenter: ImagesListPresenterProtocol?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter = ImagesListPresenter(view: self)
        presenter?.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            let photo = photos[indexPath.row] // получение фото по индексу
            if let imageURL = URL(string: photo.largeImageURL) {
                viewController.imageURL = imageURL
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func showLikeError(_ error: Error) {
        let alert = UIAlertController(
            title: "Не удалось лайкнуть фото",
            message: "\(error.localizedDescription)",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func performBatchUpdate(with indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    func indexPath(for cell: ImagesListCell) -> IndexPath? {
        return tableView.indexPath(for: cell)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        presenter?.imageListCellDidTapLike(cell)
    }
}
    //MARK: - UITableViewDataSource
    
    extension ImagesListViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return photos.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as! ImagesListCell
            let photo = photos[indexPath.row]
            
            cell.delegate = self
            if let createdAt = photo.createdAt {
                cell.dateLabel.text = dateFormatter.string(from: createdAt)
            } else {
                cell.dateLabel.text = ""
            }
            cell.likeButton.setImage(photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off"), for: .normal)
            
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(with: URL(string: photo.thumbImageURL), placeholder: UIImage(named: "placeholder_image"))
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            if indexPath.row + 1 == photos.count {
                imagesListService.fetchPhotosNextPage()
            }
        }
    }
    
    //MARK: - UITableViewDelegate
    
    extension ImagesListViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            let photo = photos[indexPath.row]
            let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
            let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
            let imageWidth = photo.size.width
            let scale = imageViewWidth / imageWidth
            let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
            return cellHeight
        }
    }


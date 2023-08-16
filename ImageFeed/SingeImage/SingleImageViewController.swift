//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Алишер Дадаметов on 30.06.2023.
//

import UIKit

class SingleImageViewController: UIViewController {
    
    private let alertPresenter = AlertPresenter()
    var imageURL: URL! {
        didSet {
            guard isViewLoaded else { return }
            imageView.kf.setImage(with: imageURL)
        }
    }
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        let share = UIActivityViewController(
            activityItems: [imageURL as Any],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIBlockingProgressHUD.show()

        imageView.kf.setImage(with: imageURL) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.alertPresenter.showAlert(
                            title: "Ошибка",
                            message: "Что-то пошло не так. Попробовать ещё раз?",
                            handler: {
                                self.loadFullImage()
                            }
                        )
            }
            
            // Уберём лоадер
            UIBlockingProgressHUD.dismiss()
        }
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func loadFullImage() {
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.alertPresenter.showAlert(
                    title: "Ошибка",
                    message: "Что-то пошло не так. Попробовать ещё раз?",
                    handler: {
                        self.loadFullImage()
                    }
                )
            }
            
            UIBlockingProgressHUD.dismiss()
        }
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

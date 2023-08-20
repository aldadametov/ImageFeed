//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Алишер Дадаметов on 09.06.2023.
//
import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    weak var delegate: ImagesListCellDelegate?
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
  
    func setIsLiked(_ isLiked: Bool) {
            let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
            likeButton.setImage(likeImage, for: .normal)
        }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
}

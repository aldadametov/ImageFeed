//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Алишер Дадаметов on 18.06.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var loginNameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var logoutButton: UIButton!
    @IBAction func didTapLogoutButton() {
    }
}

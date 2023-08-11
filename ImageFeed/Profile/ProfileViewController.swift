//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Алишер Дадаметов on 18.06.2023.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    @objc func logoutButtonTapped() {
    }
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    @IBOutlet private lazy var profileImageView: UIImageView! = {
        let profileImage = UIImage(named: "profile_Photo")
        let avatarImageView = UIImageView(image: profileImage)
        avatarImageView.tintColor = .gray
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        return avatarImageView
    }()
    
    @IBOutlet private lazy var nameLabel: UILabel! = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = .boldSystemFont(ofSize: 23)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    @IBOutlet private lazy var loginNameLabel: UILabel! = {
        let loginNameLabel = UILabel()
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.font = .systemFont(ofSize: 13)
        loginNameLabel.textColor = UIColor(hex: 0xAEAFB4)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return loginNameLabel
    }()
    
    @IBOutlet private lazy var descriptionLabel: UILabel! = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    @IBOutlet private lazy var logoutButton: UIButton! = {
        let button = UIButton.systemButton(
            with: UIImage(named: "logout_button")!,
            target: self,
            action: #selector(Self.logoutButtonTapped)
        )
        button.tintColor = UIColor(hex: 0xF56B6C)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private func updateProfileDetails(profile: Profile) {
        guard let profile = profileService.profile else { return }
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
                
        else {
            return
        }
        let cache = ImageCache.default
        cache.clearDiskCache()
        cache.clearMemoryCache()
        let processor = RoundCornerImageProcessor(cornerRadius: profileImageView.frame.width)
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: url,
                                     placeholder: UIImage(named: "person.crop.circle.fill.png"),
                                     options: [.processor(processor),.cacheSerializer(FormatIndicatedCacheSerializer.png)])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let profile = profileService.profile else {
            assertionFailure("no saved profile")
            return
        }
        profileImageService.fetchProfileImageURL(username: profile.username) {_ in}
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.DidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
        
        updateProfileDetails(profile: profile)
        
        view.addSubview(profileImageView)
        
        profileImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        
        view.addSubview(nameLabel)
        
        nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16).isActive = true
        
        view.addSubview(loginNameLabel)
        
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true
        
       
        view.addSubview(descriptionLabel)
        
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true
        
       
        view.addSubview(logoutButton)
        
        logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logoutButton.leadingAnchor.constraint(greaterThanOrEqualTo: profileImageView.leadingAnchor, constant: 0).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor(hex: 0x1A1B22)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Алишер Дадаметов on 22.08.2023.
//

import Foundation
import WebKit

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    var profile: Profile? { get }
    
    func viewDidLoad()
    func clean()
}

final class ProfileViewPresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    var profileImageServiceObserver: NSObjectProtocol?
    var profile: Profile? {
        profileService.profile
    }
    
        
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let authService = OAuth2Service()
    
    init(view: ProfileViewControllerProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        view?.updateProfileDetails(profile: profileService.profile)
        view?.updateAvatar()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.view?.updateAvatar()
        }
        
        profileImageService.fetchProfileImageURL(username: profile?.username ?? "") { _ in }
    }
    
    func clean() {
        let tokenStorage = OAuth2TokenStorage.shared
        tokenStorage.resetToken()
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

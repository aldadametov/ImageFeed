import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let alertPresenter = AlertPresenter()
    private lazy var splashScreenLogoImageView: UIImageView = {
        let splashScreenLogo = UIImage(named: "splash_screen_logo")
        let splashScreenLogoView = UIImageView(image: splashScreenLogo)
        splashScreenLogoView.translatesAutoresizingMaskIntoConstraints = false
        return splashScreenLogoView
    }()
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = oauth2TokenStorage.token {
            self.fetchProfile(token: token)
            switchToTabBarController()
        } else {
            showAuthController()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor(hex: 0x1A1B22)
        view.addSubview(splashScreenLogoImageView)
        
        NSLayoutConstraint.activate([
            splashScreenLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashScreenLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func showAuthController() {
        let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "AuthViewControllerID")
        guard let authViewController = viewController as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }

    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.fetchProfile(token: token)
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                self.showLoginAlert(error: error)
                break
            }
        }
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                guard let username = self.profileService.profile?.username else { return }
                self.profileImageService.fetchProfileImageURL(username: username)  { _ in }
                DispatchQueue.main.async {
                    self.switchToTabBarController()
                }
            case .failure(let error):
                self.showLoginAlert(error: error)
                break
            }
        }
        UIBlockingProgressHUD.dismiss()
    }
    
    private func showLoginAlert(error: Error) {
        alertPresenter.showAlert(title: "Что-то пошло не так :(",
                                 message: "Не удалось войти в систему, \(error.localizedDescription)") {
            self.showAuthController()
        }
    }
}


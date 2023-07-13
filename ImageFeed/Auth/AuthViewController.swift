//
//  SplashScreenViewController.swift
//  ImageFeed
//
//  Created by Алишер Дадаметов on 12.07.2023.
//

import UIKit

class AuthViewController: UIViewController {
    
    @IBOutlet var loginButton: UIButton!
    
    private let ShowWebViewSegueIdentifier = "ShowWebView"

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(ShowWebViewSegueIdentifier)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        //TODO: process code
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}


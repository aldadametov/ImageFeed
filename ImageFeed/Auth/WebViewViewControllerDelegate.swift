//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Алишер Дадаметов on 13.07.2023.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
    
}

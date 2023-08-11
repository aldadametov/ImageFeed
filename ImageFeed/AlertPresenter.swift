//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Алишер Дадаметов on 11.08.2023.
//

import UIKit

final class AlertPresenter {
    weak var delegate: UIViewController?
    
    func showAlert(title: String, message: String, handler: @escaping () -> Void) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            handler()
        }
        alert.addAction(alertAction)
        delegate?.present(alert, animated: true)
    }
}

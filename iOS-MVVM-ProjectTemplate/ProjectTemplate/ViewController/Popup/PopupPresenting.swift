//
//  AlertPresenting.swift
//  ProjectTemplate
//
//  Created by Marek Fořt on 10/5/18.
//

import UIKit

protocol PopupPresenting: UIViewControllerTransitioningDelegate {
    var popupAnimation: PopupModalAnimation { get }

    func present(popup: UIViewController)
}

extension PopupPresenting where Self: UIViewController {
    /// Presents popup with animation
    func present(popup: UIViewController) {
        popup.transitioningDelegate = self
        popup.modalPresentationStyle = .custom
        present(popup, animated: true)
    }
}


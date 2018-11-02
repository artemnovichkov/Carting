//
//  PopupModelAnimation.swift
//  ProjectTemplate
//
//  Created by Marek Fořt on 10/5/18.
//

import Foundation
import UIKit

/// Animation for presenting popups
final class PopupModalAnimation: NSObject, UIViewControllerAnimatedTransitioning {

    /// Popup horizontal inset
    var popupXInset: CGFloat = 19

    /// Background color for popup view
    var popupBackgroundColor: UIColor = .clear

    /// Background color for
    var backgroundColor: UIColor = .clear

    /// Visual effect for background view
    var visualEffect: UIVisualEffect? = UIBlurEffect(style: .light)

    /// Final alpha for background view
    var finalAlpha: CGFloat = 1.0

    /// Duration of presenting modal
    var presentDuration: TimeInterval = 1.0

    /// Duration of dismissing modal
    var dismissDuration: TimeInterval = 0.3

    /// Shadow offset
    let shadowOffset: CGSize = CGSize.zero

    /// Shadow color
    let shadowColor: CGColor = UIColor.black.cgColor

    /// Shadow radius
    let shadowRadius: CGFloat = 5.0

    /// Shadow opacity
    let shadowOpacity: Float = 0.5

    /// Popup animation damping
    let animationDamping: CGFloat = 0.8

    /// Initial animation spring velocity
    let animationInitialSpringVelocity: CGFloat = 1

    enum AnimationType {
        case present
        case dismiss
    }

    var animationType: AnimationType = .present

    private lazy var coverView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        view.effect = visualEffect
        view.backgroundColor = popupBackgroundColor
        return view
    }()

    @objc func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        //The view controller's view that is presenting the modal view
        let containerView = transitionContext.containerView

        if animationType == .present {
            //The modal view itself
            guard let modalView = transitionContext.viewController(forKey: .to)?.view else { return }

            coverView.alpha = 0
            containerView.addSubview(coverView)
            containerView.snp.makeConstraints({ (make) in
                make.edges.equalTo(0)
            })
            containerView.backgroundColor = backgroundColor
            coverView.frame = containerView.frame

            containerView.addSubview(modalView)
            modalView.snp.makeConstraints({ (make) in
                make.leading.trailing.equalTo(containerView).inset(popupXInset)
                make.height.lessThanOrEqualTo(containerView.snp.height).multipliedBy(0.85)
                make.center.equalTo(containerView)
            })
            modalView.layer.contentsScale = UIScreen.main.scale
            modalView.layer.shadowColor = shadowColor
            modalView.layer.shadowOffset = shadowOffset
            modalView.layer.shadowRadius = shadowRadius
            modalView.layer.shadowOpacity = shadowOpacity
            modalView.layer.masksToBounds = false
            modalView.clipsToBounds = false

            let endFrame = modalView.frame
            modalView.frame = CGRect(x: endFrame.origin.x, y: containerView.frame.size.height, width: endFrame.size.width, height: endFrame.size.height)
            containerView.bringSubviewToFront(modalView)

            //Move off of the screen so we can slide it up
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: animationDamping, initialSpringVelocity: animationInitialSpringVelocity, options: .curveLinear, animations: {
                modalView.frame = endFrame
                self.coverView.alpha = self.finalAlpha
                self.coverView.effect = self.visualEffect
                }, completion: { _ in
                    transitionContext.completeTransition(true)
            })

        } else if animationType == .dismiss {

            guard let modalView = transitionContext.viewController(forKey: .from)?.view else { return }
            //The modal view itself
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                var frame = modalView.frame
                frame.origin.y = containerView.frame.height
                modalView.layer.transform = CATransform3DRotate(modalView.layer.transform, (3.14/180) * 35, 1, 0.0, 0.0)
                self.coverView.alpha = 0
                self.coverView.effect = nil

                modalView.frame = frame
            }, completion: { _ in
                    self.coverView.removeFromSuperview()
                    transitionContext.completeTransition(true)
            })

        }
    }

    @objc func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationType == .present ? presentDuration : dismissDuration
    }
}


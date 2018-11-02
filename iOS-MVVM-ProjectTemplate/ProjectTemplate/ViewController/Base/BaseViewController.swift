import UIKit

/// Base class for all view controllers contained in app.
class BaseViewController: UIViewController, PopupPresenting {

    static var logEnabled: Bool = true

    /// Presenting modal views
    lazy var popupAnimation = PopupModalAnimation()

    /// Navigation bar is shown/hidden in viewWillAppear according to this flag
    var hasNavigationBar: Bool = true

    // MARK: Initializers

    init() {
        super.init(nibName: nil, bundle: nil)

        if BaseViewController.logEnabled {
            NSLog("📱 👶 \(self)")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: View life cycle

    override func loadView() {
        super.loadView()

        view.backgroundColor = .white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(!hasNavigationBar, animated: animated)
    }

    deinit {
        if BaseViewController.logEnabled {
            NSLog("📱 ⚰️ \(self)")
        }
    }
}

extension BaseViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        popupAnimation.animationType = .present
        return popupAnimation
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        popupAnimation.animationType = .dismiss
        return popupAnimation
    }
}

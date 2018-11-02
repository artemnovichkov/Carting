import UIKit

extension UIViewController {

    /// Goes through view controller hierarchy and returns view controller on top
    fileprivate var frontmostChild: UIViewController? {
        switch self {
        case let s as UISplitViewController: return s.viewControllers.last
        case let n as UINavigationController: return n.topViewController
        case let t as UITabBarController: return t.selectedViewController
        // Add cases for your app's container controllers...
        default: return nil
        }
    }

    var frontmostController: UIViewController {
        return presentedViewController?.frontmostController ?? frontmostChild?.frontmostController ?? self
    }
}

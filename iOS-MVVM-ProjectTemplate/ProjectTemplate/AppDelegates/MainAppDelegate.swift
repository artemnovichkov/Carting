import UIKit
import ACKategories

/// Use as classic app delegate - for app flow and lifecycle handling, appearance settings etc.
final class MainAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private lazy var appFlowCoordinator = AppFlowCoordinator()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        // swiftlint:disable force_unwrapping
        appFlowCoordinator.start(in: window!)
        return true
    }
}

import UIKit
import ACKategories

final class AppFlowCoordinator: FlowCoordinator {

    override func start(in window: UIWindow) {
        super.start(in: window)

        let vm = ExampleViewModel(dependencies: dependencies)
        let vc = ExampleViewController(viewModel: vm)

        window.rootViewController = vc

        rootViewController = vc
    }
}

import ReactiveSwift

protocol HasPushAPI {
    var pushAPI: PushAPIServicing { get }
}

protocol PushAPIServicing {
    func registerToken(_ token: String) -> SignalProducer<Void, RequestError>
}

final class PushAPIService: PushAPIServicing {
    typealias Dependencies = HasJSONAPI

    private let dependencies: Dependencies

    // MARK: Initializers

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func registerToken(_ token: String) -> SignalProducer<Void, RequestError> {
        return dependencies.jsonAPI.request(RequestAddress(path: "devices/token"), method: .put, parameters: ["token": token])
            .map { _ in }
    }
}

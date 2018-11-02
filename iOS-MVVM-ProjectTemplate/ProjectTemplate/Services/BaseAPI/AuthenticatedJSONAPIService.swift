import ACKategories
import ReactiveSwift

protocol HasAuthenticatedJSONAPI {
    var authJSONAPI: JSONAPIServicing { get }
}

final class AuthenticatedJSONAPIService: UnauthorizedHandling, JSONAPIServicing {
    typealias Dependencies = HasJSONAPI & HasAuthHandler & HasCredentialsProvider

    private let dependencies: Dependencies

    private var authorizationHeaders: HTTPHeaders { return dependencies.credentialsProvider.credentials.map { ["Authorization": "Bearer " + $0.accessToken] } ?? [:] }

    // MARK: Initializers

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: Public methods

    func request(_ address: RequestAddress, method: HTTPMethod, parameters: [String: Any], encoding: ParameterEncoding, headers: HTTPHeaders) -> SignalProducer<JSONResponse, RequestError> {
        let jsonAPI = dependencies.jsonAPI

        return authorizationHeadersProducer()
            .flatMap(.latest) { jsonAPI.request(address, method: method, parameters: parameters, encoding: encoding, headers: headers + $0) }
            .flatMapError { [unowned self] in
                self.unauthorizedHandler(error: $0, authHandler: self.dependencies.authHandler, authorizationHeaders: self.authorizationHeaders) { [unowned self] in
                    self.request(address, method: method, parameters: parameters, encoding: encoding, headers: headers)
                }
        }
    }

    func upload(_ address: RequestAddress, method: HTTPMethod = .get, parameters: [NetworkUploadable], headers: HTTPHeaders = [:]) -> SignalProducer<JSONResponse, RequestError> {
        let jsonAPI = dependencies.jsonAPI

        return authorizationHeadersProducer()
            .flatMap(.latest) { jsonAPI.upload(address, method: method, parameters: parameters, headers: headers + $0) }
            .flatMapError { [unowned self] in
                self.unauthorizedHandler(error: $0, authHandler: self.dependencies.authHandler, authorizationHeaders: self.authorizationHeaders) { [unowned self] in
                    self.upload(address, method: method, parameters: parameters, headers: headers)
                }
        }
    }

    // MARK: Private helpers

    private func authorizationHeadersProducer() -> SignalProducer<HTTPHeaders, RequestError> {
        return SignalProducer { [weak self] observer, _ in
            guard let `self` = self else { observer.sendInterrupted(); return }
            observer.send(value: self.authorizationHeaders)
            observer.sendCompleted()
        }
    }
}

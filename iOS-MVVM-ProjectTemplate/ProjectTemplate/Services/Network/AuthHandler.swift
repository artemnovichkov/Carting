import ReactiveSwift

protocol HasAuthHandler {
    var authHandler: AuthHandling { get }
}

protocol AuthHandling {
    var actions: AuthHandlingActions { get }
}

protocol AuthHandlingActions {
    var refresh: Action<RequestError?, Credentials, RequestError> { get }
}

final class AuthHandler: AuthHandling, AuthHandlingActions {
    var actions: AuthHandlingActions { return self }
    let refresh: Action<RequestError?, Credentials, RequestError> = Action { SignalProducer(error: $0 ?? .missingRefreshToken) }
}

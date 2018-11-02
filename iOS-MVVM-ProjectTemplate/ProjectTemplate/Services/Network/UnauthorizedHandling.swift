import ReactiveSwift

protocol UnauthorizedHandling { }

extension UnauthorizedHandling {
    func unauthorizedHandler<Value>(error: RequestError, authHandler: AuthHandling, authorizationHeaders: HTTPHeaders, retryFactory: @escaping () -> SignalProducer<Value, RequestError>) -> SignalProducer<Value, RequestError> {
        guard case .network(let networkError) = error, networkError.statusCode == 401 else { return SignalProducer(error: error) }

        let usedCurrentAuthData = authorizationHeaders.map { networkError.request?.allHTTPHeaderFields?[$0] == $1 }.reduce(true) { $0 && $1 }

        guard usedCurrentAuthData else { return retryFactory() }

        return SignalProducer(authHandler.actions.refresh.events)
            .filter { $0.isTerminating }
            .map { $0.isCompleted }
            .take(first: 1)
            .flatMap(.latest) { refreshSuccessful -> SignalProducer<Value, RequestError> in
                if refreshSuccessful { return retryFactory() } else { return SignalProducer(error: error) }
            }
            .on(started: {
                authHandler.actions.refresh.apply(error).start()
            })
    }
}

import Alamofire
import ReactiveSwift
import Reqres

protocol HasNetwork {
    var network: Networking { get }
}

protocol Networking {
    func request(_ address: RequestAddress, method: HTTPMethod, parameters: [String: Any], encoding: ParameterEncoding, headers: HTTPHeaders) -> SignalProducer<DataResponse, RequestError>
    func upload(_ address: RequestAddress, method: HTTPMethod, parameters: [NetworkUploadable], headers: HTTPHeaders) -> SignalProducer<DataResponse, RequestError>
}

final class Network: Networking {

    private let sessionManager: SessionManager = {
        let configuration = Reqres.defaultSessionConfiguration()
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        let alamofireManager = SessionManager(configuration: configuration)
        Reqres.sessionDelegate = alamofireManager.delegate
        return alamofireManager
    }()

    fileprivate static let networkCallbackQueue = DispatchQueue.global(qos: .background)

    // MARK: Public methods

    func request(_ address: RequestAddress, method: HTTPMethod, parameters: [String: Any], encoding: ParameterEncoding, headers: HTTPHeaders) -> SignalProducer<DataResponse, RequestError> {
        let sessionManager = self.sessionManager
        return SignalProducer { observer, lifetime in
            let task = sessionManager
                .request(address.url, method: method, parameters: parameters, encoding: encoding, headers: headers)
                .validate()
                .handleResponse(observer: observer)

            lifetime.observeEnded {
                task.cancel()
            }
        }
    }

    func upload(_ address: RequestAddress, method: HTTPMethod, parameters: [NetworkUploadable], headers: HTTPHeaders) -> SignalProducer<DataResponse, RequestError> {
        let sessionManager = self.sessionManager
        return SignalProducer { observer, _ in
            sessionManager.upload(
                multipartFormData: { multipart in parameters.forEach { $0.append(multipart: multipart) } },
                usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold,
                to: address.url,
                method: method,
                headers: headers) { encodingResult in
                    switch encodingResult {
                    case .success(let uploadRequest, _, _):
                        uploadRequest
                            .validate()
                            .handleResponse(observer: observer)

                    case .failure(let error):
                        observer.send(error: .upload(error))
                    }
            }
        }
    }
}

private extension DataRequest {
    @discardableResult
    func handleResponse(observer: Signal<DataResponse, RequestError>.Observer) -> Self {
        return responseData(queue: Network.networkCallbackQueue) { response in
            if let error = response.error {
                let networkError = NetworkError(error: error, request: response.request, response: response.response,
                                                data: response.data)

                observer.send(error: .network(networkError))
            } else if let httpResponse = response.response {
                let requestResponse = RequestResponse(statusCode: httpResponse.statusCode, request: response.request,
                                                      response: httpResponse, data: response.data)

                observer.send(value: requestResponse)
                observer.sendCompleted()
            } else {
                observer.sendInterrupted()
            }
        }
    }
}

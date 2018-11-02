import Alamofire
import Reqres

typealias DataResponse = RequestResponse<Data>
typealias JSONResponse = RequestResponse<Any>

struct RequestAddress {
    let url: URL
}

extension RequestAddress {
    // swiftlint:disable force_unwrapping
    init(path: String, baseURL: URL = URL(string: Environment.apiURLString)!) {
        url = URL(string: path, relativeTo: baseURL)!
    }
}

struct RequestResponse<Value> {
    let statusCode: Int
    let request: URLRequest?
    let response: HTTPURLResponse?
    let data: Value?

    var headers: HTTPHeaders { return response?.allHeaderFields as? HTTPHeaders ?? [:] }
}

enum RequestError: Error {
    case network(NetworkError)
    case upload(Error)
    case missingRefreshToken
}

extension RequestError: ErrorPresentable {
    var title: String? {
        switch self {
        case .missingRefreshToken, .network, .upload: return L10n.Basic.error
        }
    }

    var message: String {
        switch self {
        case .missingRefreshToken, .upload: return L10n.Basic.Error.message
        case .network(let e):
            switch (e.error as NSError).code {
            case -1001, -1009: return e.error.localizedDescription // timeout and no connection errors
            default: return L10n.Basic.Error.message
            }
        }
    }

    var detailedDescription: String? {
        switch self {
        case .missingRefreshToken, .upload: return "\(self)"
        case .network(let e):
            guard let request = e.request else {
                return "\(self)"
            }

            if let response = e.response.flatMap({ Reqres.formatResponse($0, request: e.request, method: e.request?.httpMethod, data: e.data, level: .verbose) }) {
                return Reqres.formatRequest(request, level: .verbose) + "\n\n\n\n" + response
            } else {
                return Reqres.formatError(request, error: e.error as NSError)
            }
        }
    }
}

struct NetworkError: Error {
    let error: Error
    let request: URLRequest?
    let response: HTTPURLResponse?
    let data: Data?

    var statusCode: Int? { return response?.statusCode }
}

extension RequestResponse where Value == Data {
    func jsonResponse() throws -> JSONResponse {
        let json = try data.flatMap { $0.isEmpty ? nil : try JSONSerialization.jsonObject(with: $0, options: .allowFragments) }

        return JSONResponse(statusCode: statusCode, request: request, response: response, data: json)
    }
}

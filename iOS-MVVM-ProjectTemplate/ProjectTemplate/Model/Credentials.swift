import Foundation

struct Credentials: Codable {
    let accessToken: String
    let refreshToken: String
}

enum LoginCredentials {
    case password(username: String, password: String)
}

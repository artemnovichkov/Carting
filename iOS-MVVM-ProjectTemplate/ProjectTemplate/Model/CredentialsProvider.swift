import Foundation

protocol HasCredentialsProvider {
    var credentialsProvider: CredentialsProvider { get }
}

protocol HasCredentialsStore {
    var credentialsStore: CredentialsStore { get }
}

protocol CredentialsProvider {
    var credentials: Credentials? { get }
}

protocol CredentialsStore {
    var credentials: Credentials? { get set }
}

extension UserDefaults: CredentialsProvider, CredentialsStore {
    private enum Keys {
        static var credentials = "credentials"
    }

    var credentials: Credentials? {
        get {
            guard let data = object(forKey: Keys.credentials) as? Data else { return nil }
            let decoder = JSONDecoder()
            return try? decoder.decode(Credentials.self, from: data)
        }
        set {
            if let credentials = newValue {
                let encoder = JSONEncoder()
                let data = try? encoder.encode(credentials)
                set(data, forKey: Keys.credentials)
                synchronize()
            } else {
                removeObject(forKey: Keys.credentials)
            }
        }
    }
}

extension UserDefaults {
    // swiftlint:disable force_unwrapping
    static let credentials = UserDefaults(suiteName: (Bundle.main.bundleIdentifier ?? "") + ".credentials")!
}

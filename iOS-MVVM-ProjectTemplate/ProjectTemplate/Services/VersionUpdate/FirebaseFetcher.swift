import Firebase

public class FirebaseFetcher: Fetcher {

    private let key: String
    private let remoteConfig: RemoteConfig

    public var version: Int? {
        return remoteConfig.configValue(forKey: key).numberValue?.intValue
    }

    // MARK: - Initialization

    public init(key: String) {
        self.key = key
        self.remoteConfig = RemoteConfig.remoteConfig()
    }

    // MARK: - Public interface

    public func fetch(completion: @escaping () -> Void) {
        remoteConfig.fetch(withExpirationDuration: 12 * 60 * 60) { [weak self] status, _ in
            guard status == .success else { return }
            self?.remoteConfig.activateFetched()
            completion()
        }
    }

}

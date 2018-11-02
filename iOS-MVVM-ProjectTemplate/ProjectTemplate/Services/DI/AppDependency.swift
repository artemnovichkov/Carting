import Foundation

typealias HasBaseAPIDependecies = HasNetwork & HasJSONAPI & HasAuthenticatedJSONAPI & HasAuthHandler
typealias HasAPIDependencies = HasPushAPI & HasFetcher & HasExampleAPI
typealias HasCredentialsDependencies = HasCredentialsProvider & HasCredentialsStore
typealias HasManagerDependencies = HasPushManager & HasUserManager & HasFirebasePushObserver & HasVersionUpdateManager

/// Container for all app dependencies
final class AppDependency: HasBaseAPIDependecies, HasCredentialsDependencies, HasManagerDependencies, HasAPIDependencies {
    lazy var network: Networking = Network()
    lazy var authHandler: AuthHandling = AuthHandler()

    lazy var credentialsProvider: CredentialsProvider = UserDefaults.credentials
    lazy var credentialsStore: CredentialsStore = UserDefaults.credentials

    lazy var jsonAPI: JSONAPIServicing = JSONAPIService(dependencies: self)
    lazy var authJSONAPI: JSONAPIServicing = AuthenticatedJSONAPIService(dependencies: self)
    lazy var pushAPI: PushAPIServicing = PushAPIService(dependencies: self)
    lazy var exampleAPI: ExampleAPIServicing = ExampleAPIService(dependencies: self)

    lazy var fetcher: Fetcher = FirebaseFetcher(key: "min_version")
    lazy var firebasePushObserver: FirebasePushObserving = FirebasePushObserver(dependencies: self)

    lazy var pushManager: PushManaging = PushManager(dependencies: self)
    lazy var userManager: UserManaging = UserManager()
    lazy var versionUpdateManager: VersionUpdateManaging = VersionUpdateManager(dependencies: self)
}

protocol HasNoDependency { }
extension AppDependency: HasNoDependency { }

let dependencies = AppDependency()

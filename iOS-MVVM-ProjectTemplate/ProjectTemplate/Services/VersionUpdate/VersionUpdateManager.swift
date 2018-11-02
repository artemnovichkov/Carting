import ReactiveSwift

public protocol HasVersionUpdateManager {
    var versionUpdateManager: VersionUpdateManaging { get }
}

public protocol VersionUpdateManaging {
    var updateRequired: Property<Bool> { get }

    func setup()
}

public class VersionUpdateManager: VersionUpdateManaging {
    public typealias Dependencies = HasFetcher

    public let updateRequired: Property<Bool>

    private let dependencies: Dependencies
    private let _updateRequired = MutableProperty(false)

    // MARK: Initializers 

    public init(dependencies: Dependencies) {
        updateRequired = Property(capturing: _updateRequired)
        self.dependencies = dependencies
    }

    // MARK: Public interface

    public func setup() {
        update()

        dependencies.fetcher.fetch { [weak self] in self?.update() }
    }

    // MARK: Private helpers

    private func update() {
        guard
            let currentVersion = Bundle.main.infoDictionary?["CFBundleVersion"].flatMap({ $0 as? String }).flatMap({ Int($0) }),
            let configVersion = dependencies.fetcher.version
        else { return }

        _updateRequired.value = currentVersion < configVersion
    }

}

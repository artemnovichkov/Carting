import Foundation

public protocol HasFetcher {
    var fetcher: Fetcher { get }
}

public protocol Fetcher {
    var version: Int? { get }

    func fetch(completion: @escaping () -> Void)
}

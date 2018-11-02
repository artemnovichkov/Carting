import Alamofire
import ReactiveSwift

public class APIFetcher: Fetcher {

    private let url: String
    private let keyPath: String

    private lazy var _version: Property<Int?> = Property(initial: nil, then: self._fetch.values)
    private lazy var _fetch: Action<Void, Int?, NSError> = Action { [unowned self] in
        let producer = SignalProducer<Any, NSError> { [unowned self] sink, _ in
            Alamofire.request(self.url).response {
                let request = $0.request
                let response = $0.response
                let data = $0.data
                let error = $0.error

                switch (data, error) {
                case (_, .some(let e)):
                    sink.send(error: e as NSError)
                case (.some(let d), _):
                    do {
                        let json = try JSONSerialization.jsonObject(with: d, options: .allowFragments)
                        sink.send(value: json)
                        sink.sendCompleted()
                    } catch {
                        sink.send(error: error as NSError)
                        return
                    }
                default: break
                }
            }
        }
        return producer.map {
            guard let value = ($0 as AnyObject).value(forKeyPath: self.keyPath) else { return nil }
            if let stringValue = value as? String {
                return Int(stringValue)
            }
            return value as? Int
        }
    }

    public var version: Int? { return _version.value }

    // MARK: - Initialization

    public init(url: String, keyPath: String) {
        self.url = url
        self.keyPath = keyPath
    }

    // MARK: - Public interface

    public func fetch(completion: @escaping () -> Void) {
        _fetch.apply().startWithCompleted { completion() }
    }

}

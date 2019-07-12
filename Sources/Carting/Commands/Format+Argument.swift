//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

import SPMUtility
import CartingCore

extension Format: ArgumentKind {

    enum Error: Swift.Error {
        case invalid
    }

    public static let completion: ShellCompletion = .values(Format.allCases.map { ($0.rawValue, $0.rawValue) })

    public init(argument: String) throws {
        guard let format = Format(rawValue: argument.lowercased()) else {
            throw Error.invalid
        }
        self = format
    }
}

extension Format.Error: CustomStringConvertible {

    var description: String {
        switch self {
        case .invalid:
            return "Unsupported format."
        }
    }
}

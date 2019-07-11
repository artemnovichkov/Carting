//
//  Copyright © 2017 Artem Novichkov. All rights reserved.
//

import SPMUtility

enum Format: String, ArgumentKind, CaseIterable {

    enum Error: Swift.Error {
        case invalid
    }

    case file
    case list

    static let completion: ShellCompletion = .values(Format.allCases.map { ($0.rawValue, $0.rawValue) })

    init(argument: String) throws {
        guard let format = Format(rawValue: argument.lowercased()) else {
            throw ProjectService.Error.projectReadingFailed
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

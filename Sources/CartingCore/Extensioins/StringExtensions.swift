//
//  Copyright © 2017 Artem Novichkov. All rights reserved.
//

import Foundation

extension String {

    private static let allowedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    static func randomAlphaNumericString(length: Int) -> String {
        return String((0..<length).compactMap { _ in allowedChars.randomElement() })
    }

    static let tripleTab: String = "\t\t\t"

    var quotify: String {
        return "'\(self)'"
    }

    func deleting(prefix: String) -> String {
        guard hasPrefix(prefix) else {
            return self
        }
        return String(dropFirst(prefix.count))
    }

    func deleting(suffix: String) -> String {
        guard hasSuffix(suffix) else {
            return self
        }
        return String(dropLast(suffix.count))
    }
}

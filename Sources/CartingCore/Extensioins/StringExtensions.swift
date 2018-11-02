//
//  Created by Artem Novichkov on 04/07/2017.
//

import Foundation

extension String {

    private static let allowedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    static func randomAlphaNumericString(length: Int) -> String {
        var randomString = ""

        for _ in 0..<length {
            if let character = allowedChars.randomElement() {
                randomString += String(character)
            }
        }

        return randomString
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

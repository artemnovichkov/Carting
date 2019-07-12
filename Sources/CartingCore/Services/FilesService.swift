//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

import Foundation

class FilesService {

    static func scanFiles(fromString string: String) -> [File] {
        let scanner = Scanner(string: string.trimmingCharacters(in: CharacterSet(charactersIn: "()")))
        var identifier: NSString?
        var name: NSString?
        var folder: NSString?

        var files = [File]()
        while !scanner.isAtEnd {
            scanner.scanUpTo(" /*", into: &identifier)
            scanner.scanString("/*", into: nil)
            scanner.scanUpTo(" ", into: &name)

            scanner.scanUpTo("in ", into: nil)
            scanner.scanString("in ", into: nil)
            scanner.scanUpTo(" */,", into: &folder)
            scanner.scanString("*/,", into: nil)

            if let identifier = identifier as String?,
                let name = name as String?,
                let folder = folder as String? {
                let file = File(identifier: identifier, name: name, folder: folder)
                files.append(file)
            }
        }
        return files
    }
}

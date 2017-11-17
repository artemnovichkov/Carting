//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation

struct Arguments {

    enum Command {
        case script(name: String), list, help
    }

    private enum Keys {
        static let defaultScriptName = "Carthage"
    }

    var command: Command = .help

    init?(arguments: [String]) {
        for (index, argument) in arguments.enumerated() {
            switch argument.lowercased() {
            case "-s", "--script":
                let nameIndex = index + 1
                let name = arguments.count > nameIndex ? arguments[nameIndex] : Keys.defaultScriptName
                command = .script(name: name)
            case "list":
                command = .list
            case "help":
                command = .help
            default: break
            }
        }
    }

    static let description: String = {
        return """
Usage: carting [options]
  list:
      Prints Carthage frameworks list with linking description.
  -u, --unlink:
      Unlink the framework with specified name to every target.
"""
    }()
}

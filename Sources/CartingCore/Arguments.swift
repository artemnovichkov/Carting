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
            case "update":
                command = .script(name: Keys.defaultScriptName)
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
Usage: carting [command] [options]
  update:
      Adds a new script with input/output file paths or updates the script named `Carthage`.
  -s, --script:
      Updates input/output file paths for the script with passed name.
  list:
      Prints Carthage frameworks list with linking description.
  help:
      Prints this message.
"""
    }()
}

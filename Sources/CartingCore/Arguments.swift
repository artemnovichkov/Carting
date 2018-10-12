//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation

struct Arguments {

    enum Command {
        case script(name: String), list, help
    }

    enum Format: String {
        case file, list
    }

    private enum Keys {
        static let defaultScriptName = "Carthage"
    }

    var command: Command = .help
    var path: String?
    var format: Format?

    init?(arguments: [String]) {
        for (index, argument) in arguments.enumerated() {
            switch argument.lowercased() {
            case "update":
                command = .script(name: Keys.defaultScriptName)
            case "-s", "--script":
                let nameIndex = index + 1
                let name = arguments.count > nameIndex ? arguments[nameIndex] : Keys.defaultScriptName
                command = .script(name: name)
            case "-p", "--path":
                let pathIndex = index + 1
                let path = arguments.count > pathIndex ? arguments[pathIndex] : nil
                self.path = path
            case "-f", "--format":
                let formatIndex = index + 1
                if arguments.count > formatIndex {
                    format = Format(rawValue: arguments[formatIndex]) ?? .list
                }
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
      The name of Carthage script.
  -p, --path:
      The project directory path.
  -f, --format:
      Format of input/output file paths - using simple paths or xcfilelists.
  list:
      Prints Carthage frameworks list with linking description.
  help:
      Prints this message.
"""
    }()
}

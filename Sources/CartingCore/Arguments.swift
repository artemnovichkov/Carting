//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation

struct Arguments {

    enum Command {
        case script(name: String), info, help
    }

    enum Format: String {
        case file, list
    }

    private enum Keys {
        static let defaultScriptName = "Carthage"
    }

    var command: Command = .help
    var path: String?
    var format: Format = .list

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
                if arguments.count > formatIndex, let format = Format(rawValue: arguments[formatIndex]) {
                    self.format = format
                }
            case "info":
                command = .info
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
      Format of input/output file paths:
        file - using simple paths
        list - using xcfilelists
  info:
      Prints Carthage frameworks list with linking description.
  help:
      Prints this message.
"""
    }()
}

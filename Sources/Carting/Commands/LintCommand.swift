//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

import SPMUtility
import CartingCore
import Foundation

final class LintCommand: Command {

    var command = "lint"
    var overview = "Lint the project for missing paths."

    private let name: OptionArgument<String>
    private let projectDirectoryPath: OptionArgument<String>
    private let format: OptionArgument<Format>
    private let targetName: OptionArgument<String>

    required init(parser: ArgumentParser) {
        let subparser = parser.add(subparser: command, overview: overview)
        name = subparser.add(option: "--script",
                             shortName: "-s",
                             usage: "The name of Carthage script.")
        projectDirectoryPath = subparser.add(option: "--path",
                                    shortName: "-p",
                                    usage: "The project directory path.",
                                    completion: .filename)
        format = subparser.add(option: "--format",
                               shortName: "-f",
                               usage: "Format of input/output file paths: file - using simple paths, list - using xcfilelists",
                               completion: Format.completion)
        targetName = subparser.add(option: "--target",
                                   shortName: "-t",
                                   usage: "The name of target.")
    }

    func run(with arguments: ArgumentParser.Result) throws {
        let name = arguments.get(self.name) ?? "Carthage"
        let projectDirectoryPath = arguments.get(self.projectDirectoryPath) ?? ProcessInfo.processInfo.environment["PROJECT_DIR"]
        let format = arguments.get(self.format) ?? .list
        let targetName = arguments.get(self.targetName) ?? ProcessInfo.processInfo.environment["TARGET_NAME"]
        let projectService = try ProjectService(projectDirectoryPath: projectDirectoryPath)
        try projectService.lintScript(withName: name,
                                      format: format,
                                      targetName: targetName)
    }
}

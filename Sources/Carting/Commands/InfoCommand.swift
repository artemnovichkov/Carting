//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

import SPMUtility
import CartingCore
import Foundation

final class InfoCommand: Command {

    var command = "info"
    var overview = "Prints Carthage frameworks list with linking description."

    private let projectDirectoryPath: OptionArgument<String>

    required init(parser: ArgumentParser) {
        let subparser = parser.add(subparser: command, overview: overview)
        projectDirectoryPath = subparser.add(option: "--path",
                                    shortName: "-p",
                                    usage: "The project directory path.",
                                    completion: .filename)
    }

    func run(with arguments: ArgumentParser.Result) throws {
        let projectDirectoryPath = arguments.get(self.projectDirectoryPath) ?? ProcessInfo.processInfo.environment["PROJECT_DIR"]
        let projectService = try ProjectService(projectDirectoryPath: projectDirectoryPath)
        try projectService.printFrameworksInformation()
    }
}

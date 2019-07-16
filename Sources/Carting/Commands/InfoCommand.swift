//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

import SPMUtility
import CartingCore

final class InfoCommand: Command {

    var command = "info"
    var overview = "Prints Carthage frameworks list with linking description."

    private lazy var projectService: ProjectService = .init()

    required init(parser: ArgumentParser) {
        parser.add(subparser: command, overview: overview)
    }

    func run(with arguments: ArgumentParser.Result) throws {
        try projectService.printFrameworksInformation()
    }
}

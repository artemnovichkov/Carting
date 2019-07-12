//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

import SPMUtility

public class InfoCommand: Command {

    public var command = "info"
    public var overview = "Prints Carthage frameworks list with linking description."

    private lazy var frameworkInformationService: FrameworkInformationService = .init()

    required public init(parser: ArgumentParser) {
        parser.add(subparser: command, overview: overview)
    }

    public func run(with arguments: ArgumentParser.Result) throws {
        try frameworkInformationService.printFrameworksInformation()
    }
}

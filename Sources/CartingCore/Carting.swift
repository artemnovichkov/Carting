//
//  Created by Artem Novichkov on 01/07/2017.
//

import Foundation

public final class Carting {

    private let arguments: [String]

    private lazy var frameworkInformationService: FrameworkInformationService = .init()

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
        guard let arguments = Arguments(arguments: self.arguments) else {
            print("❌ Wrong arguments")
            print(Arguments.description)
            return
        }

        frameworkInformationService.path = arguments.path
        switch arguments.command {
        case .help:
            print(Arguments.description)
        case let .script(name: name):
            try frameworkInformationService.updateScript(withName: name, path: arguments.path)
        case .list:
            frameworkInformationService.printFrameworksInformation()
        case .lint:
            frameworkInformationService.printFrameworksWarnings()
        }
    }
}

enum MainError: Swift.Error {
    case noScript(name: String)
}

extension MainError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .noScript(name: let name): return "Can't find script with name \(name)"
        }
    }
}

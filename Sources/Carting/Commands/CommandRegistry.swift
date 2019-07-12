//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

import SPMUtility
import Basic

final class CommandRegistry {

    private let parser: ArgumentParser
    private var commands: [Command] = []

    init(usage: String, overview: String) {
        parser = ArgumentParser(usage: usage, overview: overview)
    }

    func register(_ command: Command.Type) {
        commands.append(command.init(parser: parser))
    }

    func register(_ commands: [Command.Type]) {
        commands.forEach(register)
    }

    func register(_ commands: Command.Type...) {
        register(commands)
    }

    func run() throws {
        let arguments = try parse()
        try process(arguments)
    }

    // MARK: - Private

    private func parse() throws -> ArgumentParser.Result {
        let arguments = Array(CommandLine.arguments.dropFirst())
        return try parser.parse(arguments)
    }

    private func process(_ arguments: ArgumentParser.Result) throws {
        guard let subparser = arguments.subparser(parser),
            let command = commands.first(where: { $0.command == subparser }) else {
                parser.printUsage(on: stdoutStream)
                return
        }
        try command.run(with: arguments)
    }
}

//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

import Foundation
import SPMUtility
import Basic

public class CommandRegistry {

    private let parser: ArgumentParser
    private var commands: [Command] = []

    public init(usage: String, overview: String) {
        parser = ArgumentParser(usage: usage, overview: overview)
    }

    public func register(_ command: Command.Type) {
        commands.append(command.init(parser: parser))
    }

    public func register(_ commands: Command.Type...) {
        commands.forEach(register)
    }

    public func run() throws {
        let arguments = try parse()
        try process(arguments)
    }

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

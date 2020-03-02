//
//  Copyright © 2020 Artem Novichkov. All rights reserved.
//

import Foundation
import CartingCore
import ArgumentParser

struct Info: ParsableCommand {

    static let configuration: CommandConfiguration = .init(abstract: "Prints Carthage frameworks list with linking description.")

    @Option(name: [.short, .long], default: ProcessInfo.processInfo.environment["PROJECT_DIR"], help: "The project directory path.")
    var path: String?

    func run() throws {
        let projectService = try ProjectService(projectDirectoryPath: path)
        try projectService.printFrameworksInformation()
    }
}

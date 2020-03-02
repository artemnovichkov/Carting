//
//  Copyright © 2020 Artem Novichkov. All rights reserved.
//

import Foundation
import CartingCore
import ArgumentParser

struct Lint: ParsableCommand {

    static let configuration: CommandConfiguration = .init(abstract: "Lint the project for missing paths.")

    @OptionGroup()
    var options: Options

    func run() throws {
        let projectService = try ProjectService(projectDirectoryPath: options.path)
        try projectService.lintScript(withName: options.script,
                                      format: options.format,
                                      targetName: options.target,
                                      projectNames: options.projectNames)
    }
}

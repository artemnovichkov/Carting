//
//  Copyright © 2020 Artem Novichkov. All rights reserved.
//

import Foundation
import CartingCore
import ArgumentParser

struct Options: ParsableArguments {

    @Option(name: [.short, .long], default: "Carthage", help: "The name of Carthage script.")
    var script: String

    @Option(name: [.short, .long], default: ProcessInfo.processInfo.environment["PROJECT_DIR"], help: "The project directory path.")
    var path: String?

    @Option(name: [.short, .long], default: .list, help: "Format of input/output file paths: file - using simple paths, list - using xcfilelists")
    var format: Format

    @Option(name: [.short, .long], default: ProcessInfo.processInfo.environment["TARGET_NAME"], help: "The project target name.")
    var target: String?

    @Option(name: [.customShort("n"), .long], help: "The names of projects.")
    var projectNames: [String]
}

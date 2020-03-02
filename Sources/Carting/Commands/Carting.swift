//
//  Copyright © 2020 Artem Novichkov. All rights reserved.
//

import ArgumentParser

struct Carting: ParsableCommand {

    static let configuration: CommandConfiguration = .init(abstract: "🚘 Simple tool for updating Carthage script phase",
                                                           subcommands: [Update.self, Lint.self, Info.self])
}

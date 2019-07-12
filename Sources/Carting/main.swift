//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

import Foundation
import CartingCore

do {
    let registry = CommandRegistry(usage: "<command> <options>",
                                   overview: "🚘 Simple tool for updating Carthage script phase")
    registry.register(UpdateCommand.self, LintCommand.self, InfoCommand.self)
    try registry.run()
}
catch {
    print("❌ \(error)")
}

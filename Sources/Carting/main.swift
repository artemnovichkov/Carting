//
//  Created by Artem Novichkov on 01/07/2017.
//

import Foundation
import CartingCore

do {
    let registry = CommandRegistry(usage: "<command> <options>",
                                   overview: "🚘 Simple tool for updating Carthage script phase")
    registry.register(UpdateCommand.self, InfoCommand.self)
    try registry.run()
}
catch {
    print("❌ \(error)")
}

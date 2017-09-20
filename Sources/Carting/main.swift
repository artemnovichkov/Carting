//
//  Created by Artem Novichkov on 01/07/2017.
//

import Foundation
import CartingCore

let carting = Carting()

do {
    try carting.run()
}
catch {
    print("❌ \(error.localizedDescription)")
}


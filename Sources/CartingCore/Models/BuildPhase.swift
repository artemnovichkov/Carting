//
//  Created by Artem Novichkov on 04/07/2017.
//

import Foundation

final class BuildPhase {

    let identifier: String
    let name: String

    var description: String {
        return "\(identifier) /* \(name) */"
    }

    init(identifier: String, name: String) {
        self.identifier = identifier
        self.name = name
    }
}

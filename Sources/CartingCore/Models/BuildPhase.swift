//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

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

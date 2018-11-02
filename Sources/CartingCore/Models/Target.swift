//
//  Created by Artem Novichkov on 04/07/2017.
//

import Foundation

final class Target {

    let identifier: String
    let name: String
    let body: TargetBody

    var description: String {
        var string = "\n\t\t" + identifier
        string += " /* \(name) */"
        string += " = {\n"
        string += body.description
        string += "\t\t};"
        return string
    }

    init(identifier: String, name: String, body: TargetBody) {
        self.identifier = identifier
        self.name = name
        self.body = body
    }
}

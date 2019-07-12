//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

final class Script {

    let identifier: String
    let name: String
    var body: ScriptBody

    var description: String {
        var string = "\n\t\t" + identifier
        string += " /* \(name) */"
        string += " = {\n"
        string += body.description
        string += "\t\t};"
        return string
    }

    init(identifier: String, name: String, body: ScriptBody) {
        self.identifier = identifier
        self.name = name
        self.body = body
    }
}

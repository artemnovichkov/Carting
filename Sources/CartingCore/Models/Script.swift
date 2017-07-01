//
//  Script.swift
//  Carting
//
//  Created by Artem Novichkov on 29/06/2017.
//  Copyright © 2017 Artem Novichkov. All rights reserved.
//

import Foundation

class Script {
    
    let identifier: String
    let name: String
    var body: Body
    
    var description: String {
        var string = "\n\t\t" + identifier
        string += " /* \(name) */"
        string += " = {\n"
        string += body.description
        string += "\t\t};"
        return string
    }
    
    init(identifier: String, name: String, body: Body) {
        self.identifier = identifier
        self.name = name
        self.body = body
    }
}

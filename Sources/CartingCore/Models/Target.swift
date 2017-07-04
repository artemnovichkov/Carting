//
//  Target.swift
//  Carting
//
//  Created by Artem Novichkov on 04/07/2017.
//

import Foundation

class Target {
    
    let identifier: String
    let name: String
    let body: TargetBody
    
    init(identifier: String, name: String, body: TargetBody) {
        self.identifier = identifier
        self.name = name
        self.body = body
    }
}

class TargetBody {
    
    let isa: String
    let buildPhases: [BuildPhase]
    
    init(isa: String, buildPhases: [BuildPhase]) {
        self.isa = isa
        self.buildPhases = buildPhases
    }
}

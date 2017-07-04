//
//  Project.swift
//  Carting
//
//  Created by Artem Novichkov on 01/07/2017.
//  Copyright © 2017 Artem Novichkov. All rights reserved.
//

import Foundation

final class Project {
    
    let name: String
    let body: String
    let targetsRange: Range<String.Index>
    let targets: [Target]
    let scriptsRange: Range<String.Index>
    var scripts: [Script]
    
    init(name: String,
         body: String,
         targetsRange: Range<String.Index>,
         targets: [Target],
         scriptsRange: Range<String.Index>,
         scripts: [Script]) {
        self.name = name
        self.body = body
        self.targetsRange = targetsRange
        self.targets = targets
        self.scriptsRange = scriptsRange
        self.scripts = scripts
    }
}

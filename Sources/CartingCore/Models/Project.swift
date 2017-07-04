//
//  Project.swift
//  Carting
//
//  Created by Artem Novichkov on 01/07/2017.
//  Copyright © 2017 Artem Novichkov. All rights reserved.
//

import Foundation

class Project {
    
    let name: String
    let body: String
    let targets: [Target]
    let scripts: [Script]
    
    init(name: String, body: String, targets: [Target], scripts: [Script]) {
        self.name = name
        self.body = body
        self.targets = targets
        self.scripts = scripts
    }
}

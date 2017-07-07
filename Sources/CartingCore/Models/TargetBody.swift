//
//  TargetBody.swift
//  Carting
//
//  Created by Artem Novichkov on 04/07/2017.
//

import Foundation

final class TargetBody {
    
    let isa: String
    var buildPhases: [BuildPhase]
    let buildConfigurationList: String
    let buildRules: String
    let dependencies: String
    let name: String
    let productName: String
    let productReference: String
    let productType: String
    
    var description: String {
        var string = "\t\t\tisa = \(isa);\n"
        string += "\t\t\tbuildConfigurationList = \(buildConfigurationList);\n"
        string += "\t\t\tbuildPhases = (\n"
        buildPhases.forEach { phase in
            string += "\t\t\t\t\(phase.description),\n"
        }
        string += "\t\t\t);\n"
        string += "\t\t\tbuildRules = \(buildRules);\n"
        string += "\t\t\tdependencies = \(dependencies);\n"
        string += "\t\t\tname = \(name);\n"
        string += "\t\t\tproductName = \(productName);\n"
        string += "\t\t\tproductReference = \(productReference);\n"
        string += "\t\t\tproductType = \(productType);\n"
        return string
    }
    
    init(isa: String,
         buildPhases: [BuildPhase],
         buildConfigurationList: String,
         buildRules: String,
         dependencies: String,
         name: String,
         productName: String,
         productReference: String,
         productType: String) {
        self.isa = isa
        self.buildPhases = buildPhases
        self.buildConfigurationList = buildConfigurationList
        self.buildRules = buildRules
        self.dependencies = dependencies
        self.name = name
        self.productName = productName
        self.productReference = productReference
        self.productType = productType
    }
}

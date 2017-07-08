//
//  Body.swift
//  Carting
//
//  Created by Artem Novichkov on 29/06/2017.
//  Copyright © 2017 Artem Novichkov. All rights reserved.
//

import Foundation

final class ScriptBody: BaseScriptBody {
    
    var inputPaths: String
    let name: String
    var outputPaths: String
    var shellPath: String
    var shellScript: String
    
    var description: String {
        var string = "\t\t\tisa = \(isa);\n"
        string += "\t\t\tbuildActionMask = \(buildActionMask);\n"
        string += "\t\t\tfiles = \(files);\n"
        string += "\t\t\tinputPaths = \(inputPaths);\n"
        string += "\t\t\tname = \(name);\n"
        string += "\t\t\toutputPaths = \(outputPaths);\n"
        string += "\t\t\trunOnlyForDeploymentPostprocessing = \(runOnlyForDeploymentPostprocessing);\n"
        string += "\t\t\tshellPath = \(shellPath);\n"
        string += "\t\t\tshellScript = \(shellScript);\n"
        return string
    }
    
    init(isa: String = "PBXShellScriptBuildPhase",
         buildActionMask: String = "2147483647",
         files: String = "(\n\t\t\t)",
         inputPaths: String = "(\n\t\t\t)",
         name: String,
         outputPaths: String = "(\n\t\t\t)",
         runOnlyForDeploymentPostprocessing: String = "0",
         shellPath: String = "/bin/sh",
         shellScript: String = "\"\"") {
        self.inputPaths = inputPaths
        self.name = name
        self.outputPaths = outputPaths
        self.shellPath = shellPath
        self.shellScript = shellScript
        super.init(isa: isa,
                   buildActionMask: buildActionMask,
                   files: files,
                   runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
    }
}

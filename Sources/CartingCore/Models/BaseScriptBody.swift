//
//  BaseScriptBody.swift
//  Carting
//
//  Created by Artem Novichkov on 08/07/2017.
//

import Foundation

class BaseScriptBody {
    
    let isa: String
    let buildActionMask: String
    var files: [File]
    var runOnlyForDeploymentPostprocessing: String
    
    init(isa: String = "PBXShellScriptBuildPhase",
         buildActionMask: String = "2147483647",
         files: [File] = [],
         runOnlyForDeploymentPostprocessing: String = "0") {
        self.isa = isa
        self.buildActionMask = buildActionMask
        self.files = files
        self.runOnlyForDeploymentPostprocessing = runOnlyForDeploymentPostprocessing
    }
}

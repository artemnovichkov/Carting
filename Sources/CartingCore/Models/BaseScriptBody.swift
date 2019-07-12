//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

class BaseScriptBody {

    let isa: String
    let buildActionMask: String
    var files: [File]
    var runOnlyForDeploymentPostprocessing: String

    init(isa: String = "PBXShellScriptBuildPhase",
         buildActionMask: String = "\(Int32.max)",
         files: [File] = [],
         runOnlyForDeploymentPostprocessing: String = "0") {
        self.isa = isa
        self.buildActionMask = buildActionMask
        self.files = files
        self.runOnlyForDeploymentPostprocessing = runOnlyForDeploymentPostprocessing
    }
}

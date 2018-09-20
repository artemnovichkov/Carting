//
//  Created by Artem Novichkov on 29/06/2017.
//

import Foundation

final class ScriptBody: BaseScriptBody {
    
    var inputPaths: [String]
    let name: String?
    var outputPaths: [String]
    var shellPath: String
    var shellScript: String
    var showEnvVarsInLog: String?
    
    var description: String {
        var components = [.tripleTab + "isa = \(isa);"]
        components.append(.tripleTab + "buildActionMask = \(buildActionMask);")
        components.append(.tripleTab + "files = (")
        files.forEach { file in
            components.append(String.tripleTab + "\t\(file.identifier) /* \(file.name) in \(file.folder) */,")
        }
        components.append(.tripleTab + ");")
        let rawInputPaths = inputPaths.reduce("") { result, path in
            result + "\t\t\t\t\"" + path + "\","
        }
        components.append(.tripleTab + "inputPaths = (\(rawInputPaths));")
        if let name = name {
            components.append(.tripleTab + "name = \(name);")
        }
        let rawOutputPaths = outputPaths.reduce("") { result, path in
            result + "\t\t\t\t\"" + path + "\","
        }
        components.append(.tripleTab + "outputPaths = (\(rawOutputPaths));")
        components.append(.tripleTab + "runOnlyForDeploymentPostprocessing = \(runOnlyForDeploymentPostprocessing);")
        components.append(.tripleTab + "shellPath = \(shellPath);")
        if let showEnvVarsInLog = showEnvVarsInLog {
            components.append(.tripleTab + "shellScript = \(shellScript);")
            components.append(.tripleTab + "showEnvVarsInLog = \(showEnvVarsInLog);\n")
        }
        else {
            components.append(.tripleTab + "shellScript = \(shellScript);\n")
        }
        return components.joined(separator: "\n")
    }
    
    init(isa: String = "PBXShellScriptBuildPhase",
         buildActionMask: String = "2147483647",
         files: [File] = [],
         inputPaths: [String] = [],
         name: String?,
         outputPaths: [String] = [],
         runOnlyForDeploymentPostprocessing: String = "0",
         shellPath: String = "/bin/sh",
         shellScript: String = "\"\"",
         showEnvVarsInLog: String? = "0") {
        self.inputPaths = inputPaths
        self.name = name
        self.outputPaths = outputPaths
        self.shellPath = shellPath
        self.shellScript = shellScript
        self.showEnvVarsInLog = showEnvVarsInLog
        super.init(isa: isa,
                   buildActionMask: buildActionMask,
                   files: files,
                   runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
    }
}

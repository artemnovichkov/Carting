//
//  Created by Artem Novichkov on 29/06/2017.
//

import Foundation

final class ScriptBody: BaseScriptBody {

    var inputFileListPaths: [String]?
    var inputPaths: [String]
    let name: String?
    var outputFileListPaths: [String]?
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
        if let inputFileListPaths = inputFileListPaths {
            let rawInputFileListPaths = inputFileListPaths.reduce("") { result, path in
                result + "\t\t\t\t\"" + path + "\",\n"
            }
            components.append(.tripleTab + "inputFileListPaths = (\n\(rawInputFileListPaths)\t\t\t);")
        }
        let rawInputPaths = inputPaths.reduce("") { result, path in
            result + "\t\t\t\t\"" + path + "\",\n"
        }
        components.append(.tripleTab + "inputPaths = (\n\(rawInputPaths)\t\t\t);")
        if let name = name {
            components.append(.tripleTab + "name = \(name);")
        }
        if let outputFileListPaths = outputFileListPaths {
            let rawOutputFileListPaths = outputFileListPaths.reduce("") { result, path in
                result + "\t\t\t\t\"" + path + "\",\n"
            }
            components.append(.tripleTab + "outputFileListPaths = (\n\(rawOutputFileListPaths)\t\t\t);")
        }
        let rawOutputPaths = outputPaths.reduce("") { result, path in
            result + "\t\t\t\t\"" + path + "\",\n"
        }
        components.append(.tripleTab + "outputPaths = (\n\(rawOutputPaths)\t\t\t);")
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
         inputFileListPaths: [String]? = nil,
         inputPaths: [String] = [],
         name: String?,
         outputFileListPaths: [String]? = nil,
         outputPaths: [String] = [],
         runOnlyForDeploymentPostprocessing: String = "0",
         shellPath: String = "/bin/sh",
         shellScript: String = "\"\"",
         showEnvVarsInLog: String? = "0") {
        self.inputFileListPaths = inputFileListPaths
        self.inputPaths = inputPaths
        self.name = name
        self.outputFileListPaths = outputFileListPaths
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

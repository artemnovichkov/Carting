//
//  Created by Artem Novichkov on 29/06/2017.
//

import Foundation

final class ShellScriptsService {
    
    enum Error: Swift.Error {
        case scriptsReadingFailed
    }
    
    private enum Keys {
        static let buildPhaseSectionBegin = "/* Begin PBXShellScriptBuildPhase section */"
        static let buildPhaseSectionEnd = "/* End PBXShellScriptBuildPhase section */"
    }
    
    /// - Parameter string: a string from project.pbxproj file.
    /// - Returns: a tuple with a range of scripts and an array of mapped scripts. If it is a new project, returns no range and empty array.
    func scripts(fromProjectString string: String) -> (Range<String.Index>?, [Script]) {
        let (range, scriptsString) = self.scriptsString(fromProjectString: string)
        guard let nonEmptyScriptsString = scriptsString else {
            return (range, [])
        }
        let scanner = Scanner(string: nonEmptyScriptsString)
        var identifier: NSString?
        var name: NSString?
        var bodyString: NSString?
        
        var scripts = [Script]()
        while !scanner.isAtEnd {
            scanner.scanUpTo(" /*", into: &identifier)
            scanner.scanString("/*", into: nil)
            scanner.scanUpTo(" */", into: &name)
            
            scanner.scanUpTo(" = {", into: nil)
            scanner.scanString("= {", into: nil)
            scanner.scanUpTo("};", into: &bodyString)
            scanner.scanString("};", into: nil)
            
            if let name = name as String?,
                let identifier = identifier as String?,
                let body = scanBody(fromString: bodyString! as String) {
                let script = Script(identifier: identifier, name: name, body: body)
                scripts.append(script)
            }
        }
        return (range, scripts)
    }
    
    /// - Parameters:
    ///   - scripts: an array of scripts.
    ///   - needSectionBlock: if true, returns whole section block
    /// - Returns: formatted string with all scripts for insertion into project.
    func string(from scripts: [Script], needSectionBlock: Bool = false) -> String {
        let scriptStrings: [String] = scripts.map { $0.description }
        var scriptString = scriptStrings.joined(separator: "") + "\n"
        if needSectionBlock {
            scriptString = Keys.buildPhaseSectionBegin + scriptString + Keys.buildPhaseSectionEnd
        }
        return scriptString
    }
    
    /// - Parameter projectString: a string from project.pbxproj file.
    /// - Returns: a tuple with scripts range and scripts section string. If it is a new project, returns nils.
    private func scriptsString(fromProjectString string: String) -> (Range<String.Index>?, String?) {
        guard let startRange = string.range(of: Keys.buildPhaseSectionBegin),
            let endRange = string.range(of: Keys.buildPhaseSectionEnd) else {
                return (nil, nil)
        }
        let scriptsRange = startRange.upperBound..<endRange.lowerBound
        return (scriptsRange, String(string[scriptsRange]))
    }
    
    /// - Parameter string: a string of script body from curly braces.
    /// - Returns: a ScriptBody instance if there are all needed keys.
    private func scanBody(fromString string: String) -> ScriptBody? {
        let scanner = Scanner(string: string)
        var key: NSString?
        var value: NSString?
        var body = [String: String]()
        while !scanner.isAtEnd {
            scanner.scanUpTo(" = ", into: &key)
            scanner.scanString("= ", into: nil)
            scanner.scanUpTo(";\n", into: &value)
            scanner.scanString(";\n", into: nil)
            if let key = key as String?, let value = value as String? {
                body[key] = value
            }
        }
        guard
            let isa = body["isa"],
            let buildActionMask = body["buildActionMask"],
            let rawInputPaths = body["inputPaths"],
            let rawOutputPaths = body["outputPaths"],
            let runOnlyForDeploymentPostprocessing = body["runOnlyForDeploymentPostprocessing"],
            let shellPath = body["shellPath"],
            let shellScript = body["shellScript"]
            else {
                return nil
        }
        var files = [File]()
        if let filesString = body["files"] {
            files = FilesService.scanFiles(fromString: filesString)
        }
        let inputPaths = rawInputPaths.components(separatedBy: "\n").dropFirst().dropLast().compactMap { path -> String? in
            let newPath = path.deleting(prefix: "\t\t\t\t\"").deleting(suffix: "\",")
            return newPath.isEmpty ? nil : newPath
        }
        let outputPaths = rawOutputPaths.components(separatedBy: "\n").dropFirst().dropLast().compactMap { path -> String? in
            let newPath = path.deleting(prefix: "\t\t\t\t\"").deleting(suffix: "\",")
            return newPath.isEmpty ? nil : newPath
        }
        return ScriptBody(isa: isa,
                          buildActionMask: buildActionMask,
                          files: files,
                          inputPaths: inputPaths,
                          name: body["name"],
                          outputPaths: outputPaths,
                          runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing,
                          shellPath: shellPath,
                          shellScript: shellScript,
                          showEnvVarsInLog: body["showEnvVarsInLog"])
    }
}

extension ShellScriptsService.Error: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .scriptsReadingFailed: return "Can't find script section in project."
        }
    }
}

extension String {

    func deleting(prefix: String) -> String {
        guard hasPrefix(prefix) else {
            return self
        }
        return String(dropFirst(prefix.count))
    }

    func deleting(suffix: String) -> String {
        guard hasSuffix(suffix) else {
            return self
        }
        return String(dropLast(suffix.count))
    }
}

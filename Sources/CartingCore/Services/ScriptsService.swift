//
//  ScriptsService.swift
//  Carting
//
//  Created by Artem Novichkov on 29/06/2017.
//  Copyright © 2017 Artem Novichkov. All rights reserved.
//

import Foundation

final class ScriptsService {
    
    enum Error: Swift.Error {
        case noScripts
    }
    
    private enum Keys {
        static let buildPhaseSectionBegin = "/* Begin PBXShellScriptBuildPhase section */"
        static let buildPhaseSectionEnd = "/* End PBXShellScriptBuildPhase section */"
    }
    
    /// - Parameter string: script string from Build Phase section in project.
    /// - Returns: an array of mapped scripts.
    func scripts(fromProjectString string: String) throws -> (Range<String.Index>, [Script]) {
        let (range, scriptsString) = try self.scriptsString(fromProjectString: string)
        let scanner = Scanner(string: scriptsString)
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
            
            if let name = name as? String,
                let identifier = identifier as? String,
                let body = scanBody(fromString: bodyString! as String) {
                let script = Script(identifier: identifier, name: name, body: body)
                scripts.append(script)
            }
        }
        return (range, scripts)
    }
    
    /// - Parameter scripts: an array of scripts.
    /// - Returns: formatted string with all scripts for insertion into project.
    func string(from scripts: [Script]) -> String {
        let scriptStrings: [String] = scripts.map { $0.description }
        return scriptStrings.joined(separator: "") + "\n"
    }
    
    /// - Parameter projectString: a string from project.pbxproj file.
    /// - Returns: a tuple with script range and script section string.
    /// - Throws: an error if there is no script section in project string.
    private func scriptsString(fromProjectString string: String) throws -> (Range<String.Index>, String) {
        guard let startRange = string.range(of: Keys.buildPhaseSectionBegin),
            let endRange = string.range(of: Keys.buildPhaseSectionEnd) else {
                throw Error.noScripts
        }
        let scriptsRange = startRange.upperBound..<endRange.lowerBound
        return (scriptsRange, string.substring(with: scriptsRange))
    }
    
    /// - Parameter string: a string of script body from curly braces.
    /// - Returns: a body instance if there is all needed keys.
    private func scanBody(fromString string: String) -> ScriptBody? {
        let scanner = Scanner(string: string)
        var key: NSString?
        var value: NSString?
        var body = [String: String]()
        while !scanner.isAtEnd {
            scanner.scanUpTo(" = ", into: &key)
            scanner.scanString("= ", into: nil)
            scanner.scanUpTo(";", into: &value)
            scanner.scanString(";", into: nil)
            if let key = key as String?, let value = value as String? {
                body[key] = value
            }
        }
        guard
            let isa = body["isa"],
            let buildActionMask = body["buildActionMask"],
            let files = body["files"],
            let inputPaths = body["inputPaths"],
            let name = body["name"],
            let outputPaths = body["outputPaths"],
            let runOnlyForDeploymentPostprocessing = body["runOnlyForDeploymentPostprocessing"],
            let shellPath = body["shellPath"],
            let shellScript = body["shellScript"]
            else {
                return nil
        }
        return ScriptBody(isa: isa,
                          buildActionMask: buildActionMask,
                          files: files,
                          inputPaths: inputPaths,
                          name: name,
                          outputPaths: outputPaths,
                          runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing,
                          shellPath: shellPath,
                          shellScript: shellScript)
    }
}

extension ScriptsService.Error: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .noScripts: return "Can't find script section in project."
        }
    }
}

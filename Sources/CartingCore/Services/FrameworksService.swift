//
//  FrameworksService.swift
//  Carting
//
//  Created by Artem Novichkov on 08/07/2017.
//

import Foundation

final class FrameworksService {
    
    enum Error: Swift.Error {
        case noFrameworks
    }
    
    private enum Keys {
        static let frameworkPhaseSectionBegin = "/* Begin PBXFrameworksBuildPhase section */"
        static let frameworkPhaseSectionEnd = "/* End PBXFrameworksBuildPhase section */"
    }
    
    /// - Parameter string: a string from project.pbxproj file.
    /// - Returns: a tuple with a range of scripts and an array of mapped scripts.
    func scripts(fromProjectString string: String) throws -> (Range<String.Index>, [FrameworkScript]) {
        let (range, scriptsString) = try self.scriptsString(fromProjectString: string)
        let scanner = Scanner(string: scriptsString)
        var identifier: NSString?
        var name: NSString?
        var bodyString: NSString?
        
        var scripts = [FrameworkScript]()
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
                let script = FrameworkScript(identifier: identifier, name: name, body: body)
                scripts.append(script)
            }
        }
        return (range, scripts)
    }
    
    /// - Parameter projectString: a string from project.pbxproj file.
    /// - Returns: a tuple with scripts range and scripts section string.
    /// - Throws: an error if there is no scripts section in project string.
    private func scriptsString(fromProjectString string: String) throws -> (Range<String.Index>, String) {
        guard let startRange = string.range(of: Keys.frameworkPhaseSectionBegin),
            let endRange = string.range(of: Keys.frameworkPhaseSectionEnd) else {
                throw Error.noFrameworks
        }
        let scriptsRange = startRange.upperBound..<endRange.lowerBound
        return (scriptsRange, string.substring(with: scriptsRange))
    }
    
    /// - Parameter string: a string of script body from curly braces.
    /// - Returns: a ScriptBody instance if there are all needed keys.
    private func scanBody(fromString string: String) -> BaseScriptBody? {
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
            let runOnlyForDeploymentPostprocessing = body["runOnlyForDeploymentPostprocessing"]
            else {
                return nil
        }
        var files = [File]()
        if let filesString = body["files"] {
            files = FilesService.scanFiles(fromString: filesString)
        }
        return BaseScriptBody(isa: isa,
                              buildActionMask: buildActionMask,
                              files: files,
                              runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
    }
}

extension FrameworksService.Error: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .noFrameworks: return "Can't find frameworks section in project."
        }
    }
}

final class FrameworkScript {
    
    let identifier: String
    let name: String
    var body: BaseScriptBody
    
    init(identifier: String, name: String, body: BaseScriptBody) {
        self.identifier = identifier
        self.name = name
        self.body = body
    }
}

//
//  Carting.swift
//  Carting
//
//  Created by Artem Novichkov on 01/07/2017.
//

import Foundation

public final class Carting {
    
    enum Keys {
        static let defaultScriptName = "Carthage"
        static let carthageScript = "\"/usr/local/bin/carthage copy-frameworks\""
    }
    
    private let arguments: [String]
    
    private let projectService = ProjectService()
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {
        let project = try projectService.project()
        let frameworkNames = try projectService.frameworkNames()
        
        let inputPaths = projectService.pathsString(forFrameworkNames: frameworkNames, type: .input)
        let outputPaths = projectService.pathsString(forFrameworkNames: frameworkNames, type: .output)
        
        let carthageScriptName = arguments.count > 1 ? arguments[1] : Keys.defaultScriptName
        let carthageScript = project.scripts.filter { $0.name == carthageScriptName }.first
        if let carthageScript = carthageScript {
            carthageScript.body.inputPaths = inputPaths
            carthageScript.body.outputPaths = outputPaths
            carthageScript.body.shellScript = Keys.carthageScript
        }
        else {
            let identifier = String.randomAlphaNumericString(length: 24)
            let name = Keys.defaultScriptName
            let body = ScriptBody(inputPaths: inputPaths,
                                  name: name,
                                  outputPaths: outputPaths,
                                  shellScript: Keys.carthageScript)
            let script = Script(identifier: identifier, name: name, body: body)
            let buildPhase = BuildPhase(identifier: identifier, name: name)
            project.scripts.append(script)
            project.targets.first?.body.buildPhases.append(buildPhase)
        }
        
        try projectService.update(project)
        print("✅ Script \(carthageScriptName) was successfully updated.")
    }
}

enum MainError: Swift.Error {
    case noScript(name: String)
}

extension MainError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .noScript(name: let name): return "Can't find script with name \(name)"
        }
    }
}

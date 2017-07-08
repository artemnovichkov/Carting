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
        
        let carthageScriptName = arguments.count > 1 ? arguments[1] : Keys.defaultScriptName
        
        project.targets.forEach { target in
            let frameworkBuildPhase = target.body.buildPhases
                .filter { $0.name == "Frameworks" }
                .first
            let frameworkScript = project.frameworkScripts
                .filter { $0.identifier == frameworkBuildPhase?.identifier }
                .first
            guard let script = frameworkScript else {
                return
            }
            let linkedFrameworkNames = script.body.files.map { $0.name }
            
            let carthageBuildPhase = target.body.buildPhases
                .filter { $0.name == carthageScriptName }
                .first
            let carthageScript = project.scripts
                .filter { $0.identifier == carthageBuildPhase?.identifier }
                .first
            
            let inputPaths = projectService.pathsString(forFrameworkNames: linkedFrameworkNames, type: .input)
            let outputPaths = projectService.pathsString(forFrameworkNames: linkedFrameworkNames, type: .output)
            
            if let carthage = carthageScript {
                carthage.body.inputPaths = inputPaths
                carthage.body.outputPaths = outputPaths
                carthage.body.shellScript = Keys.carthageScript
            }
            else {
                let body = ScriptBody(inputPaths: inputPaths,
                                      name: carthageScriptName,
                                      outputPaths: outputPaths,
                                      shellScript: Keys.carthageScript)
                
                let identifier = String.randomAlphaNumericString(length: 24)
                let script = Script(identifier: identifier, name: carthageScriptName, body: body)
                let buildPhase = BuildPhase(identifier: identifier, name: carthageScriptName)
                project.scripts.append(script)
                target.body.buildPhases.append(buildPhase)
            }
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

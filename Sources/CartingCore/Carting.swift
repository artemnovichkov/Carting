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
        
        try project.targets.forEach { target in
            let frameworkBuildPhase = target.body.buildPhases.first { $0.name == "Frameworks" }
            let frameworkScript = project.frameworkScripts.first { $0.identifier == frameworkBuildPhase?.identifier }
            guard let script = frameworkScript else {
                return
            }
            let carthageFrameworkNames = try projectService.frameworkNames()
            let linkedCarthageFrameworkNames = script.body.files
                .filter { carthageFrameworkNames.contains($0.name) }
                .map { $0.name }
            
            let carthageBuildPhase = target.body.buildPhases.first { $0.name == carthageScriptName }
            let carthageScript = project.scripts.first { $0.identifier == carthageBuildPhase?.identifier }
            
            let inputPathsString = projectService.pathsString(forFrameworkNames: linkedCarthageFrameworkNames,
                                                              type: .input)
            let outputPathsString = projectService.pathsString(forFrameworkNames: linkedCarthageFrameworkNames,
                                                               type: .output)
            
            if let carthage = carthageScript {
                carthage.body.inputPaths = inputPathsString
                carthage.body.outputPaths = outputPathsString
                carthage.body.shellScript = Keys.carthageScript
            }
            else if linkedCarthageFrameworkNames.count > 0 {
                let body = ScriptBody(inputPaths: inputPathsString,
                                      name: carthageScriptName,
                                      outputPaths: outputPathsString,
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

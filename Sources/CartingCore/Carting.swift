//
//  Carting.swift
//  Carting
//
//  Created by Artem Novichkov on 01/07/2017.
//

import Foundation

public final class Carting {
    
    private let arguments: [String]
    
    private let projectService = ProjectService()
    private let scriptsService = ScriptsService()
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {
        let project = try projectService.project()
        let frameworkNames = try projectService.frameworkNames()
        
        let (scriptsRange, scriptString) = try scriptsService.scriptsString(fromProjectString: project.body)
        let scripts = scriptsService.scripts(fromString: scriptString)
        let carthageScriptName = arguments.count > 1 ? arguments[1] : "Carthage"
        let carthageScript = scripts.filter { $0.name == carthageScriptName }.first
        if let carthageScript = carthageScript {
            let inputPaths = projectService.pathsString(forFrameworkNames: frameworkNames, type: .input)
            let outputPaths = projectService.pathsString(forFrameworkNames: frameworkNames, type: .output)
            carthageScript.body.inputPaths = inputPaths
            carthageScript.body.outputPaths = outputPaths
        }
        else {
            throw MainError.noScript(name: carthageScriptName)
        }
        
        let newProjectString = project.body.replacingCharacters(in: scriptsRange,
                                                                with: scriptsService.string(from: scripts))
        try projectService.update(project, withString: newProjectString)
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

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
    private let targetsService = TargetsService()
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {
        let project = try projectService.project()
        print(project.targets.first?.description)
        let frameworkNames = try projectService.frameworkNames()
        
        let carthageScriptName = arguments.count > 1 ? arguments[1] : "Carthage-iOS"
        let carthageScript = project.scripts.filter { $0.name == carthageScriptName }.first
        if let carthageScript = carthageScript {
            let inputPaths = projectService.pathsString(forFrameworkNames: frameworkNames, type: .input)
            let outputPaths = projectService.pathsString(forFrameworkNames: frameworkNames, type: .output)
            carthageScript.body.inputPaths = inputPaths
            carthageScript.body.outputPaths = outputPaths
        }
        else {
            throw MainError.noScript(name: carthageScriptName)
        }
        
        let identifier = randomAlphaNumericString(length: 24)
        let name = "Test"
        let body = Body(isa: "PBXShellScriptBuildPhase",
                        buildActionMask: "2147483647",
                        files: "(\n\t\t\t)",
                        inputPaths: "(\n\t\t\t)",
                        name: name,
                        outputPaths: "(\n\t\t\t)",
                        runOnlyForDeploymentPostprocessing: "0",
                        shellPath: "/bin/sh",
                        shellScript: "\"\"")
        let script = Script(identifier: identifier, name: name, body: body)
        let buildPhase = BuildPhase(identifier: identifier, name: name)
        project.scripts.append(script)
        project.targets.first?.body.buildPhases.append(buildPhase)
        
        let newProjectString = project.body.replacingCharacters(in: project.scriptsRange,
                                                                with: scriptsService.string(from: project.scripts))
        let newTarget = newProjectString.replacingCharacters(in: project.targetsRange,
                                                             with: targetsService.string(from: project.targets))
        try projectService.update(project, withString: newTarget)
        print("✅ Script \(carthageScriptName) was successfully updated.")
    }
    
    func randomAlphaNumericString(length: Int) -> String {
        let allowedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
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

//
//  Created by Artem Novichkov on 01/07/2017.
//

import Foundation

public final class Carting {

    enum Keys {
        static let carthageScript = "\"/usr/local/bin/carthage copy-frameworks\""
    }

    private let arguments: [String]

    private let projectService = ProjectService()
    private lazy var frameworkInformationService = FrameworkInformationService()

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
        guard let arguments = Arguments(arguments: self.arguments) else {
            print("❌ Wrong arguments")
            print(Arguments.description)
            return
        }

        frameworkInformationService.path = arguments.path
        switch arguments.command {
        case .help:
            print(Arguments.description)
        case let .script(name: name):
            try updateScript(withName: name, path: arguments.path)
        case .list:
            frameworkInformationService.printFrameworksInformation()
        }
    }

    private func updateScript(withName scriptName: String, path: String?) throws {
        let project = try projectService.project(path)

        var projectHasBeenUpdated = false

        try project.targets.forEach { target in
            let frameworkBuildPhase = target.body.buildPhases.first { $0.name == "Frameworks" }
            let frameworkScript = project.frameworkScripts.first { $0.identifier == frameworkBuildPhase?.identifier }
            guard let script = frameworkScript else {
                return
            }
            let linkedCarthageDynamicFrameworkNames = try frameworkInformationService.frameworksInformation()
                .filter { information in
                    information.linking == .dynamic && script.body.files.contains { $0.name == information.name }
                }
                .map { $0.name }

            let carthageBuildPhase = target.body.buildPhases.first { $0.name == scriptName }
            let carthageScript = project.scripts.first { $0.identifier == carthageBuildPhase?.identifier }

            let inputPathsString = projectService.pathsString(forFrameworkNames: linkedCarthageDynamicFrameworkNames,
                                                              type: .input)
            let outputPathsString = projectService.pathsString(forFrameworkNames: linkedCarthageDynamicFrameworkNames,
                                                               type: .output)

            if let carthage = carthageScript {
                var scriptHasBeenUpdated = false
                if carthage.body.inputPaths != inputPathsString {
                    carthage.body.inputPaths = inputPathsString
                    scriptHasBeenUpdated = true
                }
                if carthage.body.outputPaths != outputPathsString {
                    carthage.body.outputPaths = outputPathsString
                    scriptHasBeenUpdated = true
                }
                if carthage.body.shellScript != Keys.carthageScript {
                    carthage.body.shellScript = Keys.carthageScript
                    scriptHasBeenUpdated = true
                }
                if scriptHasBeenUpdated {
                    projectHasBeenUpdated = true
                    print("✅ Script \"\(scriptName)\" in target \"\(target.name)\" was successfully updated.")
                }
            }
            else if linkedCarthageDynamicFrameworkNames.count > 0 {
                let body = ScriptBody(inputPaths: inputPathsString,
                                      name: scriptName,
                                      outputPaths: outputPathsString,
                                      shellScript: Keys.carthageScript)

                let identifier = String.randomAlphaNumericString(length: 24)
                let script = Script(identifier: identifier, name: scriptName, body: body)
                let buildPhase = BuildPhase(identifier: identifier, name: scriptName)
                project.scripts.append(script)
                target.body.buildPhases.append(buildPhase)
                print("✅ Script \(scriptName) was successfully added to \(target.name) target.")
                projectHasBeenUpdated = true
            }
        }

        if projectHasBeenUpdated {
            try projectService.update(project)
        }
        else {
            print("🤷‍♂️ Nothing to update.")
        }
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

//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Files
import ShellOut
import Foundation

final class FrameworkInformationService {

    enum Keys {
        static let carthageScript = "\"/usr/local/bin/carthage copy-frameworks\""
    }

    var path: String?

    private var projectFolder: Folder {
        if let path = path, let folder = try? Folder(path: path) {
            return folder
        }
        return FileSystem().currentFolder
    }

    private lazy var projectService: ProjectService = .init()

    // MARK: - Lifecycle

    func updateScript(withName scriptName: String, path: String?) throws {
        let project = try projectService.project(path)

        var projectHasBeenUpdated = false

        try project.targets.forEach { target in
            let frameworkBuildPhase = target.body.buildPhases.first { $0.name == "Frameworks" }
            let frameworkScript = project.frameworkScripts.first { $0.identifier == frameworkBuildPhase?.identifier }
            guard let script = frameworkScript else {
                return
            }
            let linkedCarthageDynamicFrameworkNames = try frameworksInformation()
                .filter { information in
                    information.linking == .dynamic && script.body.files.contains { $0.name == information.name }
                }
                .map { $0.name }

            let carthageBuildPhase = target.body.buildPhases.first { $0.name == scriptName }
            let carthageScript = project.scripts.first { $0.identifier == carthageBuildPhase?.identifier }

            let inputPaths = projectService.paths(forFrameworkNames: linkedCarthageDynamicFrameworkNames,
                                                  type: .input)
            let outputPaths = projectService.paths(forFrameworkNames: linkedCarthageDynamicFrameworkNames,
                                                   type: .output)

            let inputPathsString = projectService.decription(forPaths: inputPaths)
            let outputPathsString = projectService.decription(forPaths: outputPaths)

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
            else if linkedCarthageDynamicFrameworkNames.isEmpty {
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

    func frameworksInformation() throws -> [FrameworkInformation] {
        let frameworkFolder = try projectFolder.subfolder(atPath: "Carthage/Build/iOS")
        let frameworks = frameworkFolder.subfolders.filter { $0.name.hasSuffix("framework") }
        return try frameworks.map(information)
    }

    func printFrameworksInformation() throws {
        let informations = try frameworksInformation()
        informations.forEach { information in
            let description = [information.name, information.linking.rawValue].joined(separator: "\t\t") +
                "\t" +
                information.architectures.map { $0.rawValue }.joined(separator: ", ")
            print(description)
        }
    }

    func printFrameworksWarnings(path: String?) throws {
        let project = try projectService.project(path)

        var projectHasBeenUpdated = false

        try project.targets.forEach { target in
            let frameworkBuildPhase = target.body.buildPhases.first { $0.name == "Frameworks" }
            let frameworkScript = project.frameworkScripts.first { $0.identifier == frameworkBuildPhase?.identifier }
            guard let script = frameworkScript else {
                return
            }
            let linkedCarthageFrameworkNames = try frameworksInformation()
                .filter { information in
                    script.body.files.contains { $0.name == information.name }
                }
                .map { $0.name }
        }
    }

    // MARK: - Private

    private func information(for framework: Folder) throws -> FrameworkInformation {
        let path = framework.path + framework.nameExcludingExtension
        let fileOutput = try shellOut(to: "file", arguments: [path.quotify])
        let lipoOutput = try shellOut(to: "lipo", arguments: ["-info", path.quotify])
        let rawArchitectures = lipoOutput.components(separatedBy: ": ").last!
        return FrameworkInformation(name: framework.name,
                                    architectures: architectures(fromOutput: rawArchitectures),
                                    linking: linking(fromOutput: fileOutput))
    }

    private func convertFrameworkToStatic(withName name: String) throws {
        let frameworkFolder = try projectFolder.subfolder(atPath: "Carthage/Build/iOS/\(name).framework")
        let configPath = "/tmp/static.xcconfig"
        let configFile = try FileSystem().createFile(at: configPath)
        let content = "MACH_O_TYPE = staticlib"
        try configFile.write(string: content)
        setenv("XCODE_XCCONFIG_FILE", configPath, 1)

        //        let output = try shellOut(to: "export", arguments: ["XCODE_XCCONFIG_FILE=\"\(configPath)\""])
        //        print(output)
        try shellOut(to: "/usr/local/bin/carthage build", arguments: [frameworkFolder.nameExcludingExtension])

        //        let process = Process()
        //        process.environment = ["XCODE_XCCONFIG_FILE": configPath]
        //        process.launchPath = "/bin/bash"
        //        process.arguments = ["-c", "usr/local/bin/carthage build", frameworkFolder.nameExcludingExtension]
        //        process.launch()
        //        process.waitUntilExit()

        print("Done!")
    }
}

func getEnvironmentVar(_ name: String) -> String? {
    guard let rawValue = getenv(name) else { return nil }
    return String(utf8String: rawValue)
}

struct FrameworkInformation {

    enum Architecture: String {
        case i386, x86_64, armv7, arm64
    }

    enum Linking: String {
        case `static`, dynamic
    }

    let name: String
    let architectures: [Architecture]
    let linking: Linking
}

func linking(fromOutput output: String) -> FrameworkInformation.Linking {
    if output.contains("current ar archive") {
        return .static
    }
    return .dynamic
}

func architectures(fromOutput output: String) -> [FrameworkInformation.Architecture] {
    return output.components(separatedBy: " ").compactMap(FrameworkInformation.Architecture.init)
}

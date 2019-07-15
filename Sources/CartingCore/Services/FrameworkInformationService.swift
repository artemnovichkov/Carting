//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

import Files
import ShellOut
import Foundation

public final class FrameworkInformationService {

    enum Error: Swift.Error {
        case targetFilterFailed(name: String)
    }

    private enum Keys {
        static let carthageScript = "\"/usr/local/bin/carthage copy-frameworks\""
    }

    public var projectPath: String?

    private var projectFolder: Folder {
        if let path = projectPath, let folder = try? Folder(path: path) {
            return folder
        }
        return FileSystem().currentFolder
    }

    private lazy var projectService: ProjectService = .init()

    // MARK: - Lifecycle

    public init() {
    }

    public func updateScript(withName scriptName: String, format: Format, targetName: String?) throws {
        let project = try projectService.project(projectPath)

        var needUpdateProject = false
        var filelistsWereUpdated = false

        let filteredTargets = project.targets
            .filter { target in
                guard target.body.productType.isApplication else {
                    return false
                }
                if let targetName = targetName {
                    return target.name.lowercased() == targetName.lowercased()
                }
                return true
            }

        if let targetName = targetName, filteredTargets.isEmpty {
            throw Error.targetFilterFailed(name: targetName)
        }

        let carthageDynamicFrameworks = try frameworksInformation()
            .filter { information in
                information.linking == .dynamic
            }

        try filteredTargets
            .forEach { target in
                let frameworkBuildPhase = target.body.buildPhases.first { $0.name == "Frameworks" }
                let frameworkScript = project.frameworkScripts.first { $0.identifier == frameworkBuildPhase?.identifier }
                guard let script = frameworkScript else {
                    return
                }
                let linkedCarthageDynamicFrameworkNames = carthageDynamicFrameworks
                    .filter { information in
                        script.body.files.contains { $0.name == information.name }
                    }
                    .map { $0.name }

                let inputPaths = projectService.paths(forFrameworkNames: linkedCarthageDynamicFrameworkNames,
                                                      type: .input)
                let outputPaths = projectService.paths(forFrameworkNames: linkedCarthageDynamicFrameworkNames,
                                                       type: .output)

                let carthageFolder = try projectFolder.subfolder(named: "Carthage")
                let listsFolder = try carthageFolder.createSubfolderIfNeeded(withName: "xcfilelists")
                let parentFolder = carthageFolder.parent ?? projectFolder
                let path = listsFolder.path.replacingOccurrences(of: parentFolder.path, with: "$(SRCROOT)/").deleting(suffix: "/")

                let inputFileListFileName = "\(target.name)-inputPaths.xcfilelist"
                let inputFileListPath = [path, inputFileListFileName].joined(separator: "/")

                let outputFileListFileName = "\(target.name)-outputPaths.xcfilelist"
                let outputFileListPath = [path, outputFileListFileName].joined(separator: "/")

                let carthageBuildPhase = target.body.buildPhases.first { $0.name == scriptName }
                let carthageScript = project.scripts.first { $0.identifier == carthageBuildPhase?.identifier }

                if let carthage = carthageScript {
                    var scriptHasBeenUpdated = false

                    if carthage.body.shellScript != Keys.carthageScript {
                        carthage.body.shellScript = Keys.carthageScript
                        scriptHasBeenUpdated = true
                    }

                    switch format {
                    case .file:
                        scriptHasBeenUpdated = carthage.updateFiles(inputPaths: inputPaths, outputPaths: outputPaths)
                    case .list:
                        let inputFileListNewContent = inputPaths.joined(separator: "\n")
                        filelistsWereUpdated = try updateFile(in: listsFolder, withName: inputFileListFileName, content: inputFileListNewContent)

                        let outputFileListNewContent = outputPaths.joined(separator: "\n")
                        filelistsWereUpdated = try updateFile(in: listsFolder, withName: outputFileListFileName, content: outputFileListNewContent)

                        scriptHasBeenUpdated = carthage.updateFileLists(inputFileListPath: inputFileListPath, outputFileListPath: outputFileListPath)
                    }
                    if scriptHasBeenUpdated {
                        needUpdateProject = true
                        print("✅ Script \(scriptName) in target \(target.name) was successfully updated.")
                    }
                }
                else {
                    let body: ScriptBody
                    switch format {
                    case .file:
                        body = ScriptBody(inputPaths: inputPaths,
                                          name: scriptName,
                                          outputPaths: outputPaths,
                                          shellScript: Keys.carthageScript)
                    case .list:
                        body = ScriptBody(inputFileListPaths: [inputFileListPath],
                                          name: scriptName,
                                          outputFileListPaths: [outputFileListPath],
                                          shellScript: Keys.carthageScript)
                    }

                    project.addScript(withName: scriptName, body: body, to: target)
                    print("✅ Script \(scriptName) was successfully added to \(target.name) target.")
                    needUpdateProject = true
                }
            }

        if needUpdateProject {
            try projectService.update(project)
        }
        else if !filelistsWereUpdated {
            print("🤷‍♂️ Nothing to update.")
        }
    }

    public func printFrameworksInformation() throws {
        let informations = try frameworksInformation()
        informations.forEach { information in
            let description = [information.name, information.linking.rawValue].joined(separator: "\t\t") +
                "\t" +
                information.architectures.map { $0.rawValue }.joined(separator: ", ")
            print(description)
        }
    }

    public func lintScript(withName scriptName: String, format: Format, targetName: String?) throws {
        let project = try projectService.project(projectPath)

        let filteredTargets = project.targets
            .filter { target in
                guard target.body.productType.isApplication else {
                    return false
                }
                if let targetName = targetName {
                    return target.name.lowercased() == targetName.lowercased()
                }
                return true
        }

        if let targetName = targetName, filteredTargets.isEmpty {
            throw Error.targetFilterFailed(name: targetName)
        }

        let carthageDynamicFrameworks = try frameworksInformation()
            .filter { information in
                information.linking == .dynamic
        }

        try filteredTargets
            .forEach { target in
                let frameworkBuildPhase = target.body.buildPhases.first { $0.name == "Frameworks" }
                let frameworkScript = project.frameworkScripts.first { $0.identifier == frameworkBuildPhase?.identifier }
                guard let script = frameworkScript else {
                    return
                }
                let linkedCarthageDynamicFrameworkNames = carthageDynamicFrameworks
                    .filter { information in
                        script.body.files.contains { $0.name == information.name }
                    }
                    .map { $0.name }

                let inputPaths = projectService.paths(forFrameworkNames: linkedCarthageDynamicFrameworkNames,
                                                      type: .input)
                let outputPaths = projectService.paths(forFrameworkNames: linkedCarthageDynamicFrameworkNames,
                                                       type: .output)

                let carthageFolder = try projectFolder.subfolder(named: "Carthage")
                let listsFolder = try carthageFolder.createSubfolderIfNeeded(withName: "xcfilelists")
                let parentFolder = carthageFolder.parent ?? projectFolder
                let path = listsFolder.path.replacingOccurrences(of: parentFolder.path, with: "$(SRCROOT)/").deleting(suffix: "/")

                let inputFileListFileName = "\(target.name)-inputPaths.xcfilelist"
                let inputFileListPath = [path, inputFileListFileName].joined(separator: "/")

                let outputFileListFileName = "\(target.name)-outputPaths.xcfilelist"
                let outputFileListPath = [path, outputFileListFileName].joined(separator: "/")

                let carthageBuildPhase = target.body.buildPhases.first { $0.name == scriptName }
                let carthageScript = project.scripts.first { $0.identifier == carthageBuildPhase?.identifier }

                guard let carthage = carthageScript else {
                    return
                }

                var missingPaths = [String]()
                var projectInputPaths = [String]()
                var projectOutputPaths = [String]()
                switch format {
                case .file:
                    projectInputPaths = carthage.body.inputPaths
                    projectOutputPaths = carthage.body.outputPaths
                case .list:
                    if carthage.body.inputFileListPaths?.contains(inputFileListPath) == false {
                        print("error: Missing \(inputFileListPath) in \(target.name) target")
                        break
                    }
                    if let inputFile = try? listsFolder.file(named: inputFileListFileName) {
                        projectInputPaths = try inputFile.readAsString().split(separator: "\n").map(String.init)
                    }

                    if carthage.body.outputFileListPaths?.contains(outputFileListPath) == false {
                        print("error: Missing \(inputFileListPath) in \(target.name) target")
                        break
                    }
                    if let outputFile = try? listsFolder.file(named: outputFileListFileName) {
                        projectOutputPaths = try outputFile.readAsString().split(separator: "\n").map(String.init)
                    }
                }
                missingPaths.append(contentsOf:inputPaths.filter { projectInputPaths.contains($0) == false })
                missingPaths.append(contentsOf:outputPaths.filter { projectOutputPaths.contains($0) == false })
                for path in missingPaths {
                    print("error: Missing \(path) in \(target.name) target")
                }
        }
    }

    // MARK: - Private

    private func frameworksInformation() throws -> [FrameworkInformation] {
        let frameworkFolder = try projectFolder.subfolder(atPath: "Carthage/Build/iOS")
        let frameworks = frameworkFolder.subfolders.filter { $0.name.hasSuffix("framework") }
        return try frameworks.map(information)
    }

    private func information(for framework: Folder) throws -> FrameworkInformation {
        let path = framework.path + framework.nameExcludingExtension
        let fileOutput = try shellOut(to: "file", arguments: [path.quotify])
        let lipoOutput = try shellOut(to: "lipo", arguments: ["-info", path.quotify])
        let rawArchitectures = lipoOutput.components(separatedBy: ": ").last!
        return FrameworkInformation(name: framework.name,
                                    architectures: architectures(fromOutput: rawArchitectures),
                                    linking: linking(fromOutput: fileOutput))
    }

    @discardableResult
    private func updateFile(in folder: Folder, withName name: String, content: String) throws -> Bool {
        var fileWereUpdated = false
        if folder.containsFile(named: name) {
            let file = try folder.file(named: name)
            if let oldContent = try? file.readAsString(), oldContent != content {
                try shellOut(to: "chmod +w \(file.name)", at: folder.path)
                try file.write(string: content)
                fileWereUpdated = true
                print("✅ \(file.name) was successfully updated")
                try shellOut(to: "chmod -w \(file.name)", at: folder.path)
            }
        }
        else {
            let file = try folder.createFile(named: name)
            try file.write(string: content)
            fileWereUpdated = true
            print("✅ \(file.name) was successfully added")
            try shellOut(to: "chmod -w \(file.name)", at: folder.path)
        }
        return fileWereUpdated
    }
}

struct FrameworkInformation {

    enum Architecture: String {
        case i386, x86_64, armv7, arm64 //swiftlint:disable:this identifier_name
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

extension FrameworkInformationService.Error: CustomStringConvertible {

    var description: String {
        switch self {
        case .targetFilterFailed(let name): return "There is no target with \(name) name."
        }
    }
}

//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

import Files
import ShellOut
import Foundation
import XcodeProj

public final class ProjectService {

    enum Error: Swift.Error {
        case projectFileReadingFailed
        case targetFilterFailed(name: String)
    }

    private enum Keys {
        static let projectExtension = "xcodeproj"
        static let carthageScript = "/usr/local/bin/carthage copy-frameworks"
        static let inputPath = "$(SRCROOT)/Carthage/Build/iOS/"
        static let outputPath = "$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/"
    }

    enum PathType {
        case input, output
    }

    public var projectDirectory: String?

    private var projectFolder: Folder {
        if let path = projectDirectory, let folder = try? Folder(path: path) {
            return folder
        }
        return FileSystem().currentFolder
    }

    // MARK: - Lifecycle

    public init() {
    }

    public func updateScript(withName scriptName: String, format: Format, targetName: String?) throws {
        let projectPath = try self.projectPath(inDirectory: projectDirectory)
        let xcodeproj = try XcodeProj(pathString: projectPath)

        var needUpdateProject = false
        var filelistsWereUpdated = false

        let filteredTargets = xcodeproj.pbxproj.nativeTargets
            .filter { target in
                guard target.productType == .application else {
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
                let linkedCarthageDynamicFrameworkNames = target.linkedFrameworks(withNames: carthageDynamicFrameworks.map(\.name))

                let inputPaths = paths(forFrameworkNames: linkedCarthageDynamicFrameworkNames,
                                       type: .input)
                let outputPaths = paths(forFrameworkNames: linkedCarthageDynamicFrameworkNames,
                                        type: .output)

                let carthageFolder = try projectFolder.subfolder(named: "Carthage")
                let listsFolder = try carthageFolder.createSubfolderIfNeeded(withName: "xcfilelists")
                let parentFolder = carthageFolder.parent ?? projectFolder
                let xcfilelistsFolderPath = listsFolder.path
                    .replacingOccurrences(of: parentFolder.path, with: "$(SRCROOT)/")
                    .deleting(suffix: "/")

                let inputFileListFileName = "\(target.name)-inputPaths.xcfilelist"
                let inputFileListPath = [xcfilelistsFolderPath, inputFileListFileName].joined(separator: "/")

                let outputFileListFileName = "\(target.name)-outputPaths.xcfilelist"
                let outputFileListPath = [xcfilelistsFolderPath, outputFileListFileName].joined(separator: "/")

                let targetBuildPhase = target.buildPhases.first { $0.name() == scriptName }
                let projectBuildPhase = xcodeproj.pbxproj.shellScriptBuildPhases.first { $0.uuid == targetBuildPhase?.uuid }

                if let projectBuildPhase = projectBuildPhase {
                    var scriptHasBeenUpdated = false

                    if projectBuildPhase.shellScript != Keys.carthageScript {
                        projectBuildPhase.shellScript = Keys.carthageScript
                        scriptHasBeenUpdated = true
                    }

                    switch format {
                    case .file:
                        scriptHasBeenUpdated = projectBuildPhase.update(inputPaths: inputPaths, outputPaths: outputPaths)
                    case .list:
                        let inputFileListNewContent = inputPaths.joined(separator: "\n")
                        filelistsWereUpdated = try updateFile(in: listsFolder,
                                                              withName: inputFileListFileName,
                                                              content: inputFileListNewContent)

                        let outputFileListNewContent = outputPaths.joined(separator: "\n")
                        filelistsWereUpdated = try updateFile(in: listsFolder,
                                                              withName: outputFileListFileName,
                                                              content: outputFileListNewContent)

                        scriptHasBeenUpdated = projectBuildPhase.update(inputFileListPath: inputFileListPath,
                                                                        outputFileListPath: outputFileListPath)
                    }
                    if scriptHasBeenUpdated {
                        needUpdateProject = true
                        print("✅ Script \(scriptName) in target \(target.name) was successfully updated.")
                    }
                }
                else {
                    let buildPhase: PBXShellScriptBuildPhase
                    switch format {
                    case .file:
                        buildPhase = PBXShellScriptBuildPhase(name: scriptName,
                                                              inputPaths: outputPaths,
                                                              outputPaths: outputPaths,
                                                              shellScript: Keys.carthageScript)
                    case .list:
                        buildPhase = PBXShellScriptBuildPhase(name: scriptName,
                                                              inputFileListPaths: [inputFileListPath],
                                                              outputFileListPaths: [outputFileListPath],
                                                              shellScript: Keys.carthageScript)
                    }

                    target.buildPhases.append(buildPhase)
                    xcodeproj.pbxproj.add(object: buildPhase)
                    print("✅ Script \(scriptName) was successfully added to \(target.name) target.")
                    needUpdateProject = true
                }
            }

        if needUpdateProject {
            try xcodeproj.write(pathString: projectDirectory! + "/VanHaren.xcodeproj", override: true)
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
        let projectPath = try self.projectPath(inDirectory: projectDirectory)
        let xcodeproj = try XcodeProj(pathString: projectPath)

        let filteredTargets = xcodeproj.pbxproj.nativeTargets
            .filter { target in
                guard target.productType == .application else {
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
                let linkedCarthageDynamicFrameworkNames = target.linkedFrameworks(withNames: carthageDynamicFrameworks.map(\.name))

                let inputPaths = paths(forFrameworkNames: linkedCarthageDynamicFrameworkNames,
                                       type: .input)
                let outputPaths = paths(forFrameworkNames: linkedCarthageDynamicFrameworkNames,
                                        type: .output)

                let targetBuildPhase = target.buildPhases.first { $0.name() == scriptName }
                let buildPhase = xcodeproj.pbxproj.shellScriptBuildPhases.first { $0.uuid == targetBuildPhase?.uuid }

                guard let projectBuildPhase = buildPhase else {
                    return
                }

                var missingPaths = [String]()
                var projectInputPaths = [String]()
                var projectOutputPaths = [String]()
                switch format {
                case .file:
                    projectInputPaths = projectBuildPhase.inputPaths
                    projectOutputPaths = projectBuildPhase.outputPaths
                case .list:
                    let carthageFolder = try projectFolder.subfolder(named: "Carthage")
                    let listsFolder = try carthageFolder.createSubfolderIfNeeded(withName: "xcfilelists")
                    let parentFolder = carthageFolder.parent ?? projectFolder
                    let xcfilelistsFolderPath = listsFolder.path
                        .replacingOccurrences(of: parentFolder.path, with: "$(SRCROOT)/")
                        .deleting(suffix: "/")

                    let inputFileListFileName = "\(target.name)-inputPaths.xcfilelist"
                    let inputFileListPath = [xcfilelistsFolderPath, inputFileListFileName].joined(separator: "/")

                    let outputFileListFileName = "\(target.name)-outputPaths.xcfilelist"
                    let outputFileListPath = [xcfilelistsFolderPath, outputFileListFileName].joined(separator: "/")

                    if projectBuildPhase.inputFileListPaths?.contains(inputFileListPath) == false {
                        missingPaths.append(inputFileListPath)
                        break
                    }
                    if let inputFile = try? listsFolder.file(named: inputFileListFileName) {
                        projectInputPaths = try inputFile.readAsString().split(separator: "\n").map(String.init)
                    }

                    if projectBuildPhase.outputFileListPaths?.contains(outputFileListPath) == false {
                        missingPaths.append(inputFileListPath)
                        break
                    }
                    if let outputFile = try? listsFolder.file(named: outputFileListFileName) {
                        projectOutputPaths = try outputFile.readAsString().split(separator: "\n").map(String.init)
                    }
                }
                missingPaths.append(contentsOf: inputPaths.filter { projectInputPaths.contains($0) == false })
                missingPaths.append(contentsOf: outputPaths.filter { projectOutputPaths.contains($0) == false })
                for path in missingPaths {
                    print("error: Missing \(path) in \(target.name) target")
                }
                if missingPaths.isEmpty == false {
                    exit(1)
                }
            }
    }

    // MARK: - Private

    private func projectPath(inDirectory directory: String?) throws -> String {
        guard let path = directory else {
            throw Error.projectFileReadingFailed
        }
        let folder = try Folder(path: path)
        let file = folder.subfolders.first { $0.name.hasSuffix(Keys.projectExtension) }
        guard let projectFile = file else {
            throw Error.projectFileReadingFailed
        }
        return projectFile.path
    }

    private func frameworksInformation() throws -> [Framework] {
        let frameworkFolder = try projectFolder.subfolder(atPath: "Carthage/Build/iOS")
        let frameworks = frameworkFolder.subfolders.filter { $0.name.hasSuffix("framework") }
        return try frameworks.map(information)
    }

    private func information(for framework: Folder) throws -> Framework {
        let path = framework.path + framework.nameExcludingExtension
        let fileOutput = try shellOut(to: "file", arguments: [path.quotify])
        let lipoOutput = try shellOut(to: "lipo", arguments: ["-info", path.quotify])
        let rawArchitectures = lipoOutput.components(separatedBy: ": ").last!
        return Framework(name: framework.name,
                         architectures: architectures(fromOutput: rawArchitectures),
                         linking: linking(fromOutput: fileOutput))
    }

    @discardableResult
    private func updateFile(in folder: Folder, withName name: String, content: String) throws -> Bool {
        var fileWereUpdated = false
        if folder.containsFile(named: name) {
            let file = try folder.file(named: name)
            if let oldContent = try? file.readAsString(), oldContent != content {
                try shellOut(to: "chmod +w \"\(file.name)\"", at: folder.path)
                try file.write(string: content)
                fileWereUpdated = true
                print("✅ \(file.name) was successfully updated")
                try shellOut(to: "chmod -w \"\(file.name)\"", at: folder.path)
            }
        }
        else {
            let file = try folder.createFile(named: name)
            try file.write(string: content)
            fileWereUpdated = true
            print("✅ \(file.name) was successfully added")
            try shellOut(to: "chmod -w \"\(file.name)\"", at: folder.path)
        }
        return fileWereUpdated
    }

    private func paths(forFrameworkNames names: [String], type: PathType) -> [String] {
        let prefix: String
        switch type {
        case .input:
            prefix = Keys.inputPath
        case .output:
            prefix = Keys.outputPath
        }
        return names.map { frameworkName in
            return prefix + frameworkName
        }
    }
}

func linking(fromOutput output: String) -> Framework.Linking {
    if output.contains("current ar archive") {
        return .static
    }
    return .dynamic
}

func architectures(fromOutput output: String) -> [Framework.Architecture] {
    return output.components(separatedBy: " ").compactMap(Framework.Architecture.init)
}

extension ProjectService.Error: CustomStringConvertible {

    var description: String {
        switch self {
        case .projectFileReadingFailed: return "Can't find project file."
        case .targetFilterFailed(let name): return "There is no target with \(name) name."
        }
    }
}

extension PBXNativeTarget {

    func linkedFrameworks(withNames names: [String]) -> [String] {
        guard let frameworksBuildPhase = try? frameworksBuildPhase() else {
            return []
        }
        return names.filter { name in
            guard let files = frameworksBuildPhase.files else {
                return false
            }
            return files.contains { file in
                file.file?.name == name
            }
        }
    }
}

extension PBXShellScriptBuildPhase {

    @discardableResult
    func update(inputPaths: [String], outputPaths: [String]) -> Bool {
        var scriptHasBeenUpdated = false
        if inputFileListPaths?.isEmpty == false {
            inputFileListPaths?.removeAll()
            scriptHasBeenUpdated = true
        }
        if self.inputPaths != inputPaths {
            self.inputPaths = inputPaths
            scriptHasBeenUpdated = true
        }
        if outputFileListPaths?.isEmpty == false {
            outputFileListPaths?.removeAll()
            scriptHasBeenUpdated = true
        }
        if self.outputPaths != outputPaths {
            self.outputPaths = outputPaths
            scriptHasBeenUpdated = true
        }
        return scriptHasBeenUpdated
    }

    @discardableResult
    func update(inputFileListPath: String, outputFileListPath: String) -> Bool {
        var scriptHasBeenUpdated = false
        if !inputPaths.isEmpty {
            inputPaths.removeAll()
            scriptHasBeenUpdated = true
        }
        if inputFileListPaths?.first != inputFileListPath {
            inputFileListPaths = [inputFileListPath]
            scriptHasBeenUpdated = true
        }
        if outputFileListPaths?.first != outputFileListPath {
            outputFileListPaths = [outputFileListPath]
            scriptHasBeenUpdated = true
        }
        if !outputPaths.isEmpty {
            outputPaths.removeAll()
            scriptHasBeenUpdated = true
        }
        return scriptHasBeenUpdated
    }
}

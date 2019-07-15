//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

import Files
import ShellOut
import Foundation
import XcodeProj

public final class FrameworkInformationService {

    enum Error: Swift.Error {
        case targetFilterFailed(name: String)
    }

    private enum Keys {
        static let carthageScript = "/usr/local/bin/carthage copy-frameworks"
        static let inputPath = "$(SRCROOT)/Carthage/Build/iOS/"
        static let outputPath = "$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/"
    }

    enum PathType {
        case input, output
    }

    public var projectPath: String?

    private var projectFolder: Folder {
        if let path = projectPath, let folder = try? Folder(path: path) {
            return folder
        }
        return FileSystem().currentFolder
    }

    // MARK: - Lifecycle

    public init() {
    }

    public func updateScript(withName scriptName: String, format: Format, targetName: String?) throws {
        let xcodeproj = try XcodeProj(pathString: projectPath! + "/VanHaren.xcodeproj")

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
                guard let script = try target.frameworksBuildPhase() else {
                    return
                }
                let linkedCarthageDynamicFrameworkNames = carthageDynamicFrameworks
                    .filter { information in
                        guard let files = script.files else {
                            return false
                        }
                        return files.contains { file in
                            file.file?.name == information.name
                        }
                    }
                    .map(\.name)

                let inputPaths = paths(forFrameworkNames: linkedCarthageDynamicFrameworkNames,
                                       type: .input)
                let outputPaths = paths(forFrameworkNames: linkedCarthageDynamicFrameworkNames,
                                        type: .output)

                let carthageFolder = try projectFolder.subfolder(named: "Carthage")
                let listsFolder = try carthageFolder.createSubfolderIfNeeded(withName: "xcfilelists")
                let parentFolder = carthageFolder.parent ?? projectFolder
                let xcfilelistsFolderPath = listsFolder.path.replacingOccurrences(of: parentFolder.path, with: "$(SRCROOT)/").deleting(suffix: "/")

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
                        if projectBuildPhase.inputFileListPaths?.isEmpty == false {
                            projectBuildPhase.inputFileListPaths?.removeAll()
                            scriptHasBeenUpdated = true
                        }
                        if projectBuildPhase.inputPaths != inputPaths {
                            projectBuildPhase.inputPaths = inputPaths
                            scriptHasBeenUpdated = true
                        }
                        if projectBuildPhase.outputFileListPaths?.isEmpty == false {
                            projectBuildPhase.outputFileListPaths?.removeAll()
                            scriptHasBeenUpdated = true
                        }
                        if projectBuildPhase.outputPaths != outputPaths {
                            projectBuildPhase.outputPaths = outputPaths
                            scriptHasBeenUpdated = true
                        }
                    case .list:
                        let inputFileListNewContent = inputPaths.joined(separator: "\n")
                        filelistsWereUpdated = try updateFile(in: listsFolder, withName: inputFileListFileName, content: inputFileListNewContent)

                        let outputFileListNewContent = outputPaths.joined(separator: "\n")
                        filelistsWereUpdated = try updateFile(in: listsFolder, withName: outputFileListFileName, content: outputFileListNewContent)

                        if !projectBuildPhase.inputPaths.isEmpty {
                            projectBuildPhase.inputPaths.removeAll()
                            scriptHasBeenUpdated = true
                        }
                        if projectBuildPhase.inputFileListPaths?.first != inputFileListPath {
                            projectBuildPhase.inputFileListPaths = [inputFileListPath]
                            scriptHasBeenUpdated = true
                        }
                        if projectBuildPhase.outputFileListPaths?.first != outputFileListPath {
                            projectBuildPhase.outputFileListPaths = [outputFileListPath]
                            scriptHasBeenUpdated = true
                        }
                        if !projectBuildPhase.outputPaths.isEmpty {
                            projectBuildPhase.outputPaths.removeAll()
                            scriptHasBeenUpdated = true
                        }
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
                    print("✅ Script \(scriptName) was successfully added to \(target.name) target.")
                    needUpdateProject = true
                }
        }

        if needUpdateProject {
            try xcodeproj.write(pathString: projectPath! + "/VanHaren.xcodeproj", override: true)
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
        let xcodeproj = try XcodeProj(pathString: projectPath! + "/VanHaren.xcodeproj")

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
                guard let script = try target.frameworksBuildPhase() else {
                    return
                }
                let linkedCarthageDynamicFrameworkNames = carthageDynamicFrameworks
                    .filter { information in
                        guard let files = script.files else {
                            return false
                        }
                        return files.contains { file in
                            file.file?.name == information.name
                        }
                    }
                    .map(\.name)

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
                    let xcfilelistsFolderPath = listsFolder.path.replacingOccurrences(of: parentFolder.path, with: "$(SRCROOT)/").deleting(suffix: "/")

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

    /// - Parameters:
    ///   - names: names of frameworks with .framework extension, for example, "Alamofire.framework".
    ///   - type: type of path.
    /// - Returns: All paths of passed type.
    func paths(forFrameworkNames names: [String], type: PathType) -> [String] {
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

extension Array {

    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return self.map {
            $0[keyPath: keyPath]
        }
    }
}

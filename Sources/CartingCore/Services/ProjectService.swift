//
//  ProjectService.swift
//  Carting
//
//  Created by Artem Novichkov on 29/06/2017.
//  Copyright © 2017 Artem Novichkov. All rights reserved.
//

import Foundation

final class ProjectService {
    
    enum Error: Swift.Error {
        case contentsOfDirectoryReadingFailed(path: String)
        case projectFileReadingFailed
        case projectReadingFailed
        case projectResourcesReadingFailed
        case projectUpdatingFailed
    }
    
    enum PathType {
        case input, output
    }
    
    private enum Keys {
        static let projectPath = "/project.pbxproj"
        static let carthagePath = "/Carthage/Build/iOS"
        static let inputPath = "$(SRCROOT)/Carthage/Build/iOS/"
        static let outputPath = "$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/"
        static let projectExtension = "xcodeproj"
        static let frameworkExtension = "framework"
        static let resourcesBuildSectionEnd = "/* End PBXResourcesBuildPhase section */"
    }
    
    let fileManager: FileManager
    let targetsService: TargetsService
    let shellScriptsService: ShellScriptsService
    let frameworksService: FrameworksService
    
    init(fileManager: FileManager = FileManager.default,
         targetsService: TargetsService = TargetsService(),
         shellScriptsService: ShellScriptsService = ShellScriptsService(),
         frameworksService: FrameworksService = FrameworksService()) {
        self.fileManager = fileManager
        self.targetsService = targetsService
        self.shellScriptsService = shellScriptsService
        self.frameworksService = frameworksService
    }
    
    /// - Returns: a Project instance from current directory.
    /// - Throws: an error if there is no any projects.
    func project() throws -> Project {
        let path = fileManager.currentDirectoryPath
        do {
            let fileNames = try fileManager.contentsOfDirectory(atPath: path)
            let fileName = fileNames.first { $0.hasSuffix(Keys.projectExtension) }
            guard let projectFileName = fileName else {
                throw Error.projectFileReadingFailed
            }
            let path = fileManager.currentDirectoryPath + "/\(projectFileName)" + Keys.projectPath
            guard let data = fileManager.contents(atPath: path),
                let body = String(data: data, encoding: .utf8) else {
                    throw Error.projectReadingFailed
            }
            let (targetsRange, targets) = try targetsService.targets(fromProjectString: body)
            let (scriptsRange, scripts) = shellScriptsService.scripts(fromProjectString: body)
            let (_, frameworkScripts) = try frameworksService.scripts(fromProjectString: body)
            
            return Project(name: projectFileName,
                           body: body,
                           targetsRange: targetsRange,
                           targets: targets,
                           scriptsRange: scriptsRange,
                           scripts: scripts,
                           frameworkScripts: frameworkScripts)
        }
        catch {
            throw Error.contentsOfDirectoryReadingFailed(path: path)
        }
    }
    
    
    /// - Parameter project: a project for updating.
    /// - Throws: throws if it can not white a project to project file.
    func update(_ project: Project) throws {
        let newScriptsProjectString: String
        if let scriptsRange = project.scriptsRange {
            newScriptsProjectString = project.body.replacingCharacters(in: scriptsRange,
                                                                       with: shellScriptsService.string(from: project.scripts))
        }
        else if let range = project.body.range(of: Keys.resourcesBuildSectionEnd) {
            var body = project.body
            let scriptsString = shellScriptsService.string(from: project.scripts,
                                                           needSectionBlock: true)
            body.insert(contentsOf: "\n\n\(scriptsString)".characters,
                        at: range.upperBound)
            newScriptsProjectString = body
        }
        else {
            throw Error.projectResourcesReadingFailed
        }
        let newTargetsProjectString = newScriptsProjectString.replacingCharacters(in: project.targetsRange,
                                                                                  with: targetsService.string(from: project.targets))
        
        let path = fileManager.currentDirectoryPath + "/\(project.name)" + Keys.projectPath
        do {
            try newTargetsProjectString.write(toFile: path,
                                              atomically: true,
                                              encoding: .utf8)
        }
        catch {
            throw Error.projectUpdatingFailed
        }
    }
    
    /// - Parameters:
    ///   - names: names of frameworks with .framework extension, for example, "Alamofire.framework".
    ///   - type: type of path.
    /// - Returns: formatted string uncluded all paths.
    func pathsString(forFrameworkNames names: [String], type: PathType) -> String {
        switch type {
        case .input:
            let inputPaths = names.map { frameworkName in
                return Keys.inputPath + frameworkName
            }
            return decription(forPaths: inputPaths)
        case .output:
            let outputPaths = names.map { frameworkName in
                return Keys.outputPath + frameworkName
            }
            return decription(forPaths: outputPaths)
        }
    }
    
    /// - Returns: an array of iOS frameworks names built by Carthage.
    /// - Throws: ar error if there is no Carthage folder.
    func frameworkNames() throws -> [String] {
        let path = fileManager.currentDirectoryPath + Keys.carthagePath
        do {
            let fileNames = try fileManager.contentsOfDirectory(atPath: path)
            return fileNames.filter { $0.hasSuffix(Keys.frameworkExtension) }
        }
        catch {
            throw Error.contentsOfDirectoryReadingFailed(path: path)
        }
    }
    
    private func decription(forPaths paths: [String]) -> String {
        var string = "(\n"
        paths.forEach { path in
            string += .tripleTab + "\t\"\(path)\",\n"
        }
        string += .tripleTab + ")"
        return string
    }
}

extension ProjectService.Error: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .contentsOfDirectoryReadingFailed(let path): return "Can't get content of directory at path \(path)."
        case .projectFileReadingFailed: return "Can't find project file."
        case .projectReadingFailed: return "Can't read the project."
        case .projectResourcesReadingFailed: return "Can't fine Resources section in the project."
        case .projectUpdatingFailed: return "Can't update the project."
        }
    }
}

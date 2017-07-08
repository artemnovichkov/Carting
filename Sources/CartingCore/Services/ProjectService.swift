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
        case noProjectFile
        case cannotReadProject
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
        let fileNames = try fileManager.contentsOfDirectory(atPath: fileManager.currentDirectoryPath)
        let projectFileNames = fileNames.filter { file in
            return file.hasSuffix(Keys.projectExtension)
        }
        guard let projectFileName = projectFileNames.first else {
            throw Error.noProjectFile
        }
        let path = fileManager.currentDirectoryPath + "/\(projectFileName)" + Keys.projectPath
        guard let data = fileManager.contents(atPath: path),
            let body = String(data: data, encoding: .utf8) else {
                throw Error.cannotReadProject
        }
        let (targetsRange, targets) = try targetsService.targets(fromProjectString: body)
        let (scriptsRange, scripts) = try shellScriptsService.scripts(fromProjectString: body)
        let (frameworksRange, frameworkScripts) = try frameworksService.scripts(fromProjectString: body)
        frameworkScripts.forEach { script in
            print(script.body.files)
        }
        
        return Project(name: projectFileName,
                       body: body,
                       targetsRange: targetsRange,
                       targets: targets,
                       scriptsRange: scriptsRange,
                       scripts: scripts)
    }
    
    
    /// - Parameter project: a project for updating.
    /// - Throws: throws if it can not white a project to project file.
    func update(_ project: Project) throws {
        let newScriptsProjectString = project.body.replacingCharacters(in: project.scriptsRange,
                                                                       with: shellScriptsService.string(from: project.scripts))
        let newTargetsProjectString = newScriptsProjectString.replacingCharacters(in: project.targetsRange,
                                                                                  with: targetsService.string(from: project.targets))
        
        let path = fileManager.currentDirectoryPath + "/\(project.name)" + Keys.projectPath
        try newTargetsProjectString.write(toFile: path,
                         atomically: true,
                         encoding: .utf8)
    }
    
    /// - Returns: an array of iOS frameworks names built by Carthage.
    /// - Throws: ar error if there is no Carthage folder.
    func frameworkNames() throws -> [String] {
        let fileNames = try fileManager.contentsOfDirectory(atPath: fileManager.currentDirectoryPath + Keys.carthagePath)
        return fileNames.filter { file in
            return file.hasSuffix(Keys.frameworkExtension)
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
    
    private func decription(forPaths paths: [String]) -> String {
        var string = "(\n"
        paths.forEach { path in
            string += "\t\t\t\t\"\(path)\",\n"
        }
        string += "\t\t\t)"
        return string
    }
}

extension ProjectService.Error: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .noProjectFile: return "Can't find any .pbxproj file."
        case .cannotReadProject: return "Can't read a project."
        }
    }
}

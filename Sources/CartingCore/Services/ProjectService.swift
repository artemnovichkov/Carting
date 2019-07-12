//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
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

    /// - Parameter path: The project directory path.
    /// - Returns: a Project instance from current directory.
    /// - Throws: an error if there is no any projects.
    func project(_ path: String? = nil) throws -> Project {
        let projectDirectoryPath = path ?? fileManager.currentDirectoryPath
        do {
            let fileNames = try fileManager.contentsOfDirectory(atPath: projectDirectoryPath)
            let fileName = fileNames.first { $0.hasSuffix(Keys.projectExtension) }
            guard let projectFileName = fileName else {
                throw Error.projectFileReadingFailed
            }
            let projectFilePath = projectDirectoryPath + "/\(projectFileName)" + Keys.projectPath
            guard let data = fileManager.contents(atPath: projectFilePath),
                let body = String(data: data, encoding: .utf8) else {
                    throw Error.projectReadingFailed
            }
            let (targetsRange, targets) = try targetsService.targets(fromProjectString: body)
            let (scriptsRange, scripts) = shellScriptsService.scripts(fromProjectString: body)
            let (_, frameworkScripts) = try frameworksService.scripts(fromProjectString: body)

            return Project(path: projectDirectoryPath,
                           name: projectFileName,
                           body: body,
                           targetsRange: targetsRange,
                           targets: targets,
                           scriptsRange: scriptsRange,
                           scripts: scripts,
                           frameworkScripts: frameworkScripts)
        }
        catch {
            throw Error.contentsOfDirectoryReadingFailed(path: projectDirectoryPath)
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
            body.insert(contentsOf: "\n\n\(scriptsString)", at: range.upperBound)
            newScriptsProjectString = body
        }
        else {
            throw Error.projectResourcesReadingFailed
        }
        let newTargetsProjectString = newScriptsProjectString.replacingCharacters(in: project.targetsRange,
                                                                                  with: targetsService.string(from: project.targets))

        let path = project.path + "/\(project.name)" + Keys.projectPath
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

    /// - Parameter path: The project directory path.
    /// - Returns: an array of iOS frameworks names built by Carthage.
    /// - Throws: ar error if there is no Carthage folder.
    func frameworkNames(_ path: String? = nil) throws -> [String] {
        let path = path ?? fileManager.currentDirectoryPath + Keys.carthagePath
        do {
            let fileNames = try fileManager.contentsOfDirectory(atPath: path)
            return fileNames.lazy.filter { $0.hasSuffix(Keys.frameworkExtension) }
        }
        catch {
            throw Error.contentsOfDirectoryReadingFailed(path: path)
        }
    }

    /// Formatted description for passed paths.
    ///
    /// - Parameter paths: Paths for frameworks.
    /// - Returns: formatted string uncluded all paths.
    func description(forPaths paths: [String]) -> String {
        var string = "(\n"
        paths.forEach { path in
            string += .tripleTab + "\t\"\(path)\",\n"
        }
        string += .tripleTab + ")"
        return string
    }
}

extension ProjectService.Error: CustomStringConvertible {

    var description: String {
        switch self {
        case .contentsOfDirectoryReadingFailed(let path): return "Can't get content of directory at path \(path)."
        case .projectFileReadingFailed: return "Can't find project file."
        case .projectReadingFailed: return "Can't read the project."
        case .projectResourcesReadingFailed: return "Can't fine Resources section in the project."
        case .projectUpdatingFailed: return "Can't update the project."
        }
    }
}

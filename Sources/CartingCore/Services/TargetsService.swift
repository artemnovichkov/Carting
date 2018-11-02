//
//  Created by Artem Novichkov on 04/07/2017.
//

import Foundation

final class TargetsService {
    
    enum Error: Swift.Error {
        case targetsReadingFailed
    }
    
    private enum Keys {
        static let targetSectionBegin = "/* Begin PBXNativeTarget section */"
        static let targetSectionEnd = "/* End PBXNativeTarget section */"
    }
    
    /// - Parameter string: a string from project.pbxproj file.
    /// - Returns: a tuple with a range of scripts and an array of mapped targets.
    func targets(fromProjectString string: String) throws -> (Range<String.Index>, [Target]) {
        let (range, targetsString) = try self.targetsString(fromProjectString: string)
        let scanner = Scanner(string: targetsString)
        var identifier: NSString?
        var name: NSString?
        var bodyString: NSString?

        var targets = [Target]()
        while !scanner.isAtEnd {
            scanner.scanUpTo(" /*", into: &identifier)
            scanner.scanString("/*", into: nil)
            scanner.scanUpTo(" */", into: &name)

            scanner.scanUpTo(" = {", into: nil)
            scanner.scanString("= {", into: nil)
            scanner.scanUpTo("};", into: &bodyString)
            scanner.scanString("};", into: nil)

            if let name = name as String?,
                let identifier = identifier as String?,
                let body = scanBody(fromString: bodyString! as String) {
                let target = Target(identifier: identifier, name: name, body: body)
                targets.append(target)
            }
        }
        return (range, targets)
    }

    /// - Parameter scripts: an array of targets.
    /// - Returns: formatted string with all targets for insertion into project.
    func string(from targets: [Target]) -> String {
        let targetStrings: [String] = targets.map { $0.description }
        return targetStrings.joined() + "\n"
    }
    
    /// - Parameter projectString: a string from project.pbxproj file.
    /// - Returns: a tuple with targets range and targets section string.
    /// - Throws: an error if there is no targets section in project string.
    private func targetsString(fromProjectString projectString: String) throws -> (Range<String.Index>, String) {
        guard
            let targetsStartRange = projectString.range(of: Keys.targetSectionBegin),
            let targetsEndRange = projectString.range(of: Keys.targetSectionEnd) else {
                throw Error.targetsReadingFailed
        }

        let targetsRange = targetsStartRange.upperBound..<targetsEndRange.lowerBound
        return (targetsRange, String(projectString[targetsRange]))
    }

    /// - Parameter string: a string of target body from curly braces.
    /// - Returns: a TargetBody instance if there are all needed keys.
    private func scanBody(fromString string: String) -> TargetBody? {
        let scanner = Scanner(string: string)
        var key: NSString?
        var value: NSString?
        var body = [String: String]()
        while !scanner.isAtEnd {
            scanner.scanUpTo(" = ", into: &key)
            scanner.scanString("= ", into: nil)
            scanner.scanUpTo(";", into: &value)
            scanner.scanString(";", into: nil)
            if let key = key as String?, let value = value as String? {
                body[key] = value
            }
        }
        guard
            let isa = body["isa"],
        let buildPhases = body["buildPhases"],
        let buildConfigurationList = body["buildConfigurationList"],
        let buildRules = body["buildRules"],
        let dependencies = body["dependencies"],
        let name = body["name"],
        let productName = body["productName"],
        let productReference = body["productReference"],
        let productTypeRaw = body["productType"]
            else {
                return nil
        }
        let productType = ProductType(productTypeRaw)
        let set = CharacterSet(charactersIn: "()")
        let rawBody = buildPhases.trimmingCharacters(in: set)
        let phases = scanBuildPhases(fromString: rawBody)
        return TargetBody(isa: isa,
                          buildPhases: phases,
                          buildConfigurationList: buildConfigurationList,
                          buildRules: buildRules,
                          dependencies: dependencies,
                          name: name,
                          productName: productName,
                          productReference: productReference,
                          productType: productType)
    }

    /// - Parameter string: a string of build phases.
    /// - Returns: an array of mapped build phases.
    private func scanBuildPhases(fromString string: String) -> [BuildPhase] {
        let scanner = Scanner(string: string)
        var identifier: NSString?
        var name: NSString?
        
        var buildPhases = [BuildPhase]()
        while !scanner.isAtEnd {
            scanner.scanUpTo(" /*", into: &identifier)
            scanner.scanString("/*", into: nil)
            scanner.scanUpTo(" */,", into: &name)
            scanner.scanString("*/,", into: nil)

            if let name = name as String?,
                let identifier = identifier as String? {
                let buildPhase = BuildPhase(identifier: identifier, name: name)
                buildPhases.append(buildPhase)
            }
        }
        return buildPhases
    }
}

extension TargetsService.Error: CustomStringConvertible {

    var description: String {
        switch self {
        case .targetsReadingFailed: return "Can't find target section in project."
        }
    }
}

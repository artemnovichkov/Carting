//
//  TargetsService.swift
//  Carting
//
//  Created by Artem Novichkov on 04/07/2017.
//

import Foundation

final class TargetsService {
    
    enum Error: Swift.Error {
        case noTargets
    }
    
    private enum Keys {
        static let targetSectionBegin = "/* Begin PBXNativeTarget section */"
        static let targetSectionEnd = "/* End PBXNativeTarget section */"
    }
    
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
            
            if let name = name as? String,
                let identifier = identifier as? String,
                let body = scanBody(fromString: bodyString! as String) {
                let target = Target(identifier: identifier, name: name, body: body)
                targets.append(target)
            }
        }
        return (range, targets)
    }
    
    private func targetsString(fromProjectString projectString: String) throws -> (Range<String.Index>, String) {
        guard
            let targetsStartRange = projectString.range(of: Keys.targetSectionBegin),
            let targetsEndRange = projectString.range(of: Keys.targetSectionEnd) else {
                throw Error.noTargets
        }
        
        let targetsRange = targetsStartRange.upperBound..<targetsEndRange.lowerBound
        return (targetsRange, projectString.substring(with: targetsRange))
    }
    
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
            let isa = body["isa"]
            else {
                return nil
        }
        let set = CharacterSet(charactersIn: "()")
        let rawBody = body["buildPhases"]!.trimmingCharacters(in: set)
        let buildPhases = scanBuildPhases(fromString: rawBody)
        return TargetBody(isa: isa,
                          buildPhases: buildPhases)
    }
    
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
            
            if let name = name as? String,
                let identifier = identifier as? String {
                let buildPhase = BuildPhase(identifier: identifier, name: name)
                buildPhases.append(buildPhase)
            }
        }
        return buildPhases
    }
}

extension TargetsService.Error: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .noTargets: return "Can't find target section in project."
        }
    }
}

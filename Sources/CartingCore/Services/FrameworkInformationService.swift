//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Files
import ShellOut
import Foundation

class FrameworkInformationService {

    func frameworksInformation() throws -> [FrameworkInformation] {
        let frameworkFolder = try FileSystem().currentFolder.subfolder(atPath: "Carthage/Build/iOS")
        let frameworks = frameworkFolder.subfolders.filter { $0.name.hasSuffix("framework") }
        return try frameworks.lazy.map(information)
    }

    func printFrameworksInformation() {
        do {
            let informations = try frameworksInformation()
            informations.forEach { information in
                let description = [information.name, information.linking.rawValue].joined(separator: "\t\t") +
                    "\t" +
                    information.architectures.map { $0.rawValue }.joined(separator: ", ")
                print(description)
            }
        }
        catch {
            print(error)
        }
    }

    func information(for framework: Folder) throws -> FrameworkInformation {
        let path = framework.path + framework.nameExcludingExtension
        let fileOutput = try shellOut(to: "file", arguments: [path])
        let lipoOutput = try shellOut(to: "lipo", arguments: ["-info", path])
        let rawArchitectures = lipoOutput.components(separatedBy: ": ").last!
        return FrameworkInformation(name: framework.name,
                                    architectures: architectures(fromOutput: rawArchitectures),
                                    linking: linking(fromOutput: fileOutput))
    }

    private func convertFrameworkToStatic(withName name: String) throws {
        let frameworkFolder = try FileSystem().currentFolder.subfolder(atPath: "Carthage/Build/iOS/\(name).framework")
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
    return output.components(separatedBy: " ").flatMap { FrameworkInformation.Architecture(rawValue: $0) }
}

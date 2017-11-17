//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Files
import ShellOut

class FrameworkInformationService {

    func printFrameworksList() {
        do {
            let frameworkFolder = try FileSystem().currentFolder.subfolder(atPath: "Carthage/Build/iOS")
            let frameworks = frameworkFolder.subfolders.filter { $0.name.hasSuffix("framework") }
            let informations = try frameworks.map(information)
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

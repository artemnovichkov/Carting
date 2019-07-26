//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

import XcodeProj

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

    func paths(for frameworks: [Framework], type: PathType) -> [String] {
        let linkedCarthageDynamicFrameworkNames = linkedFrameworks(withNames: frameworks.map(\.name))

        return linkedCarthageDynamicFrameworkNames.map { frameworkName in
            return type.prefix + frameworkName
        }
    }
}

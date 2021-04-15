//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

import XcodeProj

extension XcodeProj {
    
    func targets(with type: PBXProductType, name: String?) -> [PBXNativeTarget] {
        return pbxproj.nativeTargets
            .filter { target in
                guard target.productType == type else {
                    return false
                }
                if let name = name {
                    return target.name.lowercased() == name.lowercased()
                }
                return true
            }
    }
    
    func targets(with types: [PBXProductType], name: String?) -> [PBXNativeTarget] {
        return pbxproj.nativeTargets
            .filter { target in
                guard let productType = target.productType else { return false }
                guard types.contains(productType) else {
                    return false
                }
                if let name = name {
                    return target.name.lowercased() == name.lowercased()
                }
                return true
            }
    }
}

//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

enum PathType {
    case input, output

    var prefix: String {
        switch self {
        case .input:
            return "$(SRCROOT)/Carthage/Build/iOS/"
        case .output:
            return "$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/"
        }
    }
}

//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//


struct Framework {

    enum Architecture: String {
        case i386, x86_64, armv7, arm64 //swiftlint:disable:this identifier_name
    }

    enum Linking: String {
        case `static`, dynamic
    }

    let name: String
    let architectures: [Architecture]
    let linking: Linking
}

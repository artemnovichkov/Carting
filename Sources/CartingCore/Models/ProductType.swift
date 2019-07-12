//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

import Foundation

struct ProductType {
    private let value: String

    init(value: String) {
        self.value = value
    }

    var description: String {
        return value
    }

    var isApplication: Bool {
        return value.replacingOccurrences(of: "\"", with: "") == "com.apple.product-type.application"
    }
}

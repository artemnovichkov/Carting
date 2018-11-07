//
// Created by Alexey Korolev on 07/11/2018.
//

import Foundation

struct ProductType {
    private let value: String
    init(value: String) {
        self.value = value
    }

    var description: String {
        return self.value
    }

    var isApplication: Bool {
        switch self.value {
        case "\"com.apple.product-type.application\"":
            return true
        default:
            return false
        }
    }
}

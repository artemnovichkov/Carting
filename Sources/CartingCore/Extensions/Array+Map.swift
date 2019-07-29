//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

extension Array {

    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return self.map {
            $0[keyPath: keyPath]
        }
    }
}

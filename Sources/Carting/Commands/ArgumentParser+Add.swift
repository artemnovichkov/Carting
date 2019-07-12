//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

import SPMUtility

extension ArgumentParser {

    func add<T: ArgumentKind>(option: String, shortName: String? = nil, usage: String? = nil, completion: ShellCompletion? = nil) -> OptionArgument<T> {
        return add(option: option, shortName: shortName, kind: T.self, usage: usage, completion: completion)
    }

    func add<T: ArgumentKind>(option: String, shortName: String? = nil, usage: String? = nil, completion: ShellCompletion? = nil) -> OptionArgument<[T]> {
        return add(option: option, shortName: shortName, kind: [T].self, usage: usage, completion: completion)
    }

    func add<T: ArgumentKind>(positional: String, optional: Bool = false, usage: String? = nil, completion: ShellCompletion? = nil) -> PositionalArgument<T> {
        return add(positional: positional, kind: T.self, optional: optional, usage: usage, completion: completion)
    }

    func add<T: ArgumentKind>(positional: String, optional: Bool = false, usage: String? = nil, completion: ShellCompletion? = nil) -> PositionalArgument<[T]> {
        return add(positional: positional, kind: [T].self, optional: optional, usage: usage, completion: completion)
    }
}

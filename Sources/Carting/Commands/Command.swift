//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

import SPMUtility

protocol Command {

    var command: String { get }
    var overview: String { get }

    init(parser: ArgumentParser)
    func run(with arguments: ArgumentParser.Result) throws
}

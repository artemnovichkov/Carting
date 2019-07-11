//
//  Created by Artem Novichkov on 08/07/2017.
//

import Foundation

final class File {

    let identifier: String
    let name: String
    let folder: String

    init(identifier: String, name: String, folder: String) {
        self.identifier = identifier
        self.name = name
        self.folder = folder
    }
}

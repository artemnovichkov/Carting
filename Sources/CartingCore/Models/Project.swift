//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

final class Project {

    let path: String
    let name: String
    let body: String
    let targetsRange: Range<String.Index>
    let targets: [Target]
    let scriptsRange: Range<String.Index>?
    var scripts: [Script]
    var frameworkScripts: [FrameworkScript]

    init(path: String,
         name: String,
         body: String,
         targetsRange: Range<String.Index>,
         targets: [Target],
         scriptsRange: Range<String.Index>?,
         scripts: [Script],
         frameworkScripts: [FrameworkScript]) {
        self.path = path
        self.name = name
        self.body = body
        self.targetsRange = targetsRange
        self.targets = targets
        self.scriptsRange = scriptsRange
        self.scripts = scripts
        self.frameworkScripts = frameworkScripts
    }
}

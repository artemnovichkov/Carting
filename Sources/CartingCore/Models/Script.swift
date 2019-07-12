//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

final class Script {

    let identifier: String
    let name: String
    var body: ScriptBody

    var description: String {
        var string = "\n\t\t" + identifier
        string += " /* \(name) */"
        string += " = {\n"
        string += body.description
        string += "\t\t};"
        return string
    }

    init(identifier: String, name: String, body: ScriptBody) {
        self.identifier = identifier
        self.name = name
        self.body = body
    }

    @discardableResult
    func updateFiles(inputPaths: [String], outputPaths: [String]) -> Bool {
        var scriptHasBeenUpdated = false
        if body.inputFileListPaths?.isEmpty == false {
            body.inputFileListPaths?.removeAll()
            scriptHasBeenUpdated = true
        }
        if body.inputPaths != inputPaths {
            body.inputPaths = inputPaths
            scriptHasBeenUpdated = true
        }
        if body.outputFileListPaths?.isEmpty == false {
            body.outputFileListPaths?.removeAll()
            scriptHasBeenUpdated = true
        }
        if body.outputPaths != outputPaths {
            body.outputPaths = outputPaths
            scriptHasBeenUpdated = true
        }
        return scriptHasBeenUpdated
    }

    @discardableResult
    func updateFileLists(inputFileListPath: String, outputFileListPath: String) -> Bool {
        var scriptHasBeenUpdated = false
        if !body.inputPaths.isEmpty {
            body.inputPaths.removeAll()
            scriptHasBeenUpdated = true
        }
        if body.inputFileListPaths?.first != inputFileListPath {
            body.inputFileListPaths = [inputFileListPath]
            scriptHasBeenUpdated = true
        }
        if body.outputFileListPaths?.first != outputFileListPath {
            body.outputFileListPaths = [outputFileListPath]
            scriptHasBeenUpdated = true
        }
        if !body.outputPaths.isEmpty {
            body.outputPaths.removeAll()
            scriptHasBeenUpdated = true
        }
        return scriptHasBeenUpdated
    }
}

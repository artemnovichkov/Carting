//
//  Copyright © 2019 Artem Novichkov. All rights reserved.
//

import XcodeProj

extension PBXShellScriptBuildPhase {

    @discardableResult
    func update(shellScript: String) -> Bool {
        if self.shellScript != shellScript {
            self.shellScript = shellScript
            return true
        }
        return false
    }

    @discardableResult
    func update(inputPaths: [String], outputPaths: [String]) -> Bool {
        var scriptHasBeenUpdated = false
        if inputFileListPaths?.isEmpty == false {
            inputFileListPaths?.removeAll()
            scriptHasBeenUpdated = true
        }
        if self.inputPaths != inputPaths {
            self.inputPaths = inputPaths
            scriptHasBeenUpdated = true
        }
        if outputFileListPaths?.isEmpty == false {
            outputFileListPaths?.removeAll()
            scriptHasBeenUpdated = true
        }
        if self.outputPaths != outputPaths {
            self.outputPaths = outputPaths
            scriptHasBeenUpdated = true
        }
        return scriptHasBeenUpdated
    }

    @discardableResult
    func update(inputFileListPath: String, outputFileListPath: String) -> Bool {
        var scriptHasBeenUpdated = false
        if !inputPaths.isEmpty {
            inputPaths.removeAll()
            scriptHasBeenUpdated = true
        }
        if inputFileListPaths?.first != inputFileListPath {
            inputFileListPaths = [inputFileListPath]
            scriptHasBeenUpdated = true
        }
        if outputFileListPaths?.first != outputFileListPath {
            outputFileListPaths = [outputFileListPath]
            scriptHasBeenUpdated = true
        }
        if !outputPaths.isEmpty {
            outputPaths.removeAll()
            scriptHasBeenUpdated = true
        }
        return scriptHasBeenUpdated
    }
}

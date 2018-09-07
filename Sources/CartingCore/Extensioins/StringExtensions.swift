//
//  Created by Artem Novichkov on 04/07/2017.
//

import Foundation

extension String {
    
    static func randomAlphaNumericString(length: Int) -> String {
        let allowedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""
        
        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
    static var tripleTab: String {
        return "\t\t\t"
    }

    var quotify: String {
        return "'\(self)'"
    }
}

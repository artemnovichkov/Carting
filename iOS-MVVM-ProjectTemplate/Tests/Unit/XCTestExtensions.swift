//
//  XCTestExtensions.swift
//  UnitTests
//
//  Created by Jakub Olejník on 01/02/2018.
//

import XCTest

extension XCTestCase {
    func async(timeout: TimeInterval = 0.5, testBlock: ((XCTestExpectation) -> ())) {
        let expectation = self.expectation(description: "")
        testBlock(expectation)
        waitForExpectations(timeout: timeout, handler: {
            if let error = $0 { XCTFail(error.localizedDescription) }
        })
    }
}

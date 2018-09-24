//
//  StateTests.swift
//  Framezilla
//
//  Created by Nikita on 06/09/16.
//  Copyright © 2016 Nikita. All rights reserved.
//

import XCTest
@testable import Framezilla

class StateTests: BaseTest {

    private let view1 = UIView()
    private let view2 = UIView()
    
    override func setUp() {
        
        super.setUp()
        view1.frame = .zero
    }
    
    /* single view */
    
    func testThatCorrectlyConfiguresFrameForSingleView() {
        
        view1.nx_state = 1
        configureFramesForSingleView()
        XCTAssertEqual(view1.frame, CGRect(x: 0, y: 0, width: 40, height: 20))
        
        view1.nx_state = DEFAULT_STATE
        configureFramesForSingleView()
        XCTAssertEqual(view1.frame, CGRect(x: 0, y: 0, width: 10, height: 10))
        
        view1.nx_state = 2
        configureFramesForSingleView()
        XCTAssertEqual(view1.frame, CGRect(x: 0, y: 0, width: 5, height: 5))
        
        view1.nx_state = 3
        configureFramesForSingleView()
        XCTAssertEqual(view1.frame, CGRect(x: 0, y: 0, width: 5, height: 5))
    }
    
    private func configureFramesForSingleView() {
        
        view1.frame = .zero
        
        view1.configureFrame { maker in
            maker.width(10)
            maker.height(10)
        }
        
        view1.configureFrame(state: 1) { maker in
            maker.width(40)
            maker.height(20)
        }
        
        view1.configureFrame(states: [2,3]) { maker in
            maker.width(5)
            maker.height(5)
        }
    }
    
    /* array of views */
    
    func testThatCorrectlyConfiguresFramesForArrayOfViews() {
        
        view1.nx_state = 1
        view2.nx_state = 1
        configureFramesForArrayOfViews()
        XCTAssertEqual(view1.frame, CGRect(x: 0, y: 0, width: 20, height: 20))
        XCTAssertEqual(view2.frame, CGRect(x: 0, y: 0, width: 20, height: 20))
        
        view1.nx_state = DEFAULT_STATE
        view2.nx_state = DEFAULT_STATE
        configureFramesForArrayOfViews()
        XCTAssertEqual(view1.frame, CGRect(x: 0, y: 0, width: 10, height: 10))
        XCTAssertEqual(view2.frame, CGRect(x: 0, y: 0, width: 10, height: 10))
        
        view1.nx_state = 2
        view2.nx_state = 2
        configureFramesForArrayOfViews()
        XCTAssertEqual(view1.frame, CGRect(x: 0, y: 0, width: 30, height: 30))
        XCTAssertEqual(view2.frame, CGRect(x: 0, y: 0, width: 30, height: 30))
        
        view1.nx_state = 3
        view2.nx_state = 3
        configureFramesForArrayOfViews()
        XCTAssertEqual(view1.frame, CGRect(x: 0, y: 0, width: 30, height: 30))
        XCTAssertEqual(view2.frame, CGRect(x: 0, y: 0, width: 30, height: 30))
    }
    
    private func configureFramesForArrayOfViews() {
        
        view1.frame = .zero
        view2.frame = .zero
        
        [view1, view2].configureFrames { maker in
            maker.width(10)
            maker.height(10)
        }
        
        [view1, view2].configureFrames(state: 1) { maker in
            maker.width(20)
            maker.height(20)
        }
        
        [view1, view2].configureFrames(states: [2,3]) { maker in
            maker.width(30)
            maker.height(30)
        }
    }
}

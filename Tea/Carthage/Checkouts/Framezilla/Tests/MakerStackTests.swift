//
//  MakerStackTests.swift
//  Framezilla
//
//  Created by Nikita Ermolenko on 19/02/2017.
//
//

import XCTest
@testable import Framezilla

class MakerStackTests: BaseTest {
    
    private let containterView = UIView()
    
    private var view1: UIView!
    private var view2: UIView!
    private var view3: UIView!
    
    override func setUp() {
        
        super.setUp()
        
        view1 = UIView()
        view2 = UIView()
        view3 = UIView()
        
        containterView.addSubview(view1)
        containterView.addSubview(view2)
        containterView.addSubview(view3)
    }
    
    override func tearDown() {
        
        containterView.frame = .zero
        
        view1.removeFromSuperview()
        view2.removeFromSuperview()
        view3.removeFromSuperview()
        
        super.tearDown()
    }
    
    /* horizontal */
    
    func testThatCorrectlyConfigures_horizontal_stack_withoutSpacing() {
        
        containterView.frame = CGRect(x: 0, y: 0, width: 90, height: 200)

        [view1, view2, view3].stack(axis: .horizontal)

        XCTAssertEqual(view1.frame, CGRect(x: 0, y: 0, width: 30, height: 200))
        XCTAssertEqual(view2.frame, CGRect(x: 30, y: 0, width: 30, height: 200))
        XCTAssertEqual(view3.frame, CGRect(x: 60, y: 0, width: 30, height: 200))
    }
    
    func testThatCorrectlyConfigures_horizontal_stack_withSpacing() {
        
        containterView.frame = CGRect(x: 0, y: 0, width: 96, height: 200)

        [view1, view2, view3].stack(axis: .horizontal, spacing: 3)
        
        XCTAssertEqual(view1.frame, CGRect(x: 0, y: 0, width: 30, height: 200))
        XCTAssertEqual(view2.frame, CGRect(x: 33, y: 0, width: 30, height: 200))
        XCTAssertEqual(view3.frame, CGRect(x: 66, y: 0, width: 30, height: 200))
    }
    
    /* vertical */
    
    func testThatCorrectlyConfigures_vertical_stack_withoutSpacing() {
        
        containterView.frame = CGRect(x: 0, y: 0, width: 200, height: 90)

        [view1, view2, view3].stack(axis: .vertical)
        
        XCTAssertEqual(view1.frame, CGRect(x: 0, y: 0, width: 200, height: 30))
        XCTAssertEqual(view2.frame, CGRect(x: 0, y: 30, width: 200, height: 30))
        XCTAssertEqual(view3.frame, CGRect(x: 0, y: 60, width: 200, height: 30))
    }
    
    func testThatCorrectlyConfigures_vertical_stack_withSpacing() {
        
        containterView.frame = CGRect(x: 0, y: 0, width: 200, height: 96)

        [view1, view2, view3].stack(axis: .vertical, spacing: 3)
        
        XCTAssertEqual(view1.frame, CGRect(x: 0, y: 0, width: 200, height: 30))
        XCTAssertEqual(view2.frame, CGRect(x: 0, y: 33, width: 200, height: 30))
        XCTAssertEqual(view3.frame, CGRect(x: 0, y: 66, width: 200, height: 30))
    }
    
    /* state */
    
    func testThatCorrectlyConfiguresStackForOtherStates() {
        
        containterView.frame = CGRect(x: 0, y: 0, width: 90, height: 200)
        containterView.nx_state = "STATE"
        configuresFrames()
        
        XCTAssertEqual(view1.frame, CGRect(x: 0, y: 0, width: 30, height: 200))
        XCTAssertEqual(view2.frame, CGRect(x: 30, y: 0, width: 30, height: 200))
        XCTAssertEqual(view3.frame, CGRect(x: 60, y: 0, width: 30, height: 200))
        
        containterView.frame = CGRect(x: 0, y: 0, width: 200, height: 90)
        containterView.nx_state = DEFAULT_STATE
        configuresFrames()
        
        XCTAssertEqual(view1.frame, CGRect(x: 0, y: 0, width: 200, height: 30))
        XCTAssertEqual(view2.frame, CGRect(x: 0, y: 30, width: 200, height: 30))
        XCTAssertEqual(view3.frame, CGRect(x: 0, y: 60, width: 200, height: 30))
        
    }
    
    private func configuresFrames() {
        view1.frame = .zero
        view2.frame = .zero
        view3.frame = .zero
        
        [view1, view2, view3].stack(axis: .vertical)
        [view1, view2, view3].stack(axis: .horizontal, state: "STATE")
    }
}

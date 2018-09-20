//
//  MakerCenterTests.swift
//  Framezilla
//
//  Created by Nikita on 06/09/16.
//  Copyright © 2016 Nikita. All rights reserved.
//

import XCTest

class MakerCenterTests: BaseTest {
    
    /* center - between views */
    
    func testThanCorrectlyConfigures_centerX_betweenTwoViews() {
        
        let view1 = UIView()
        let view2 = UIView()
        let view3 = UIView()
        
        mainView.addSubview(view1)
        mainView.addSubview(view2)
        mainView.addSubview(view3)
        
        view1.configureFrame { maker in
            maker.edges(top: 0, left: 0, bottom: 0)
            maker.width(100)
        }
        
        view2.configureFrame { maker in
            maker.edges(top: 0, bottom: 0, right: 0)
            maker.width(200)
        }
        
        view3.configureFrame { maker in
            maker.size(width: 20, height: 30)
            maker.centerX(between: view1, view2)
            maker.centerY()
        }
        
        XCTAssertEqual(view3.frame, CGRect(x: 190, y: 235, width: 20, height: 30))

        view3.frame = .zero
        view3.configureFrame { maker in
            maker.size(width: 20, height: 30)
            maker.centerX(between: view2, view1)
            maker.centerY()
        }

        XCTAssertEqual(view3.frame, CGRect(x: 190, y: 235, width: 20, height: 30))
    }

    func testThanCorrectlyConfigures_centerY_betweenTwoViews() {
        
        let view1 = UIView()
        let view2 = UIView()
        let view3 = UIView()
        
        mainView.addSubview(view1)
        mainView.addSubview(view2)
        mainView.addSubview(view3)
        
        view1.configureFrame { maker in
            maker.edges(top: 0, left: 0, right: 0)
            maker.height(100)
        }
        
        view2.configureFrame { maker in
            maker.edges(left: 0, bottom: 0, right: 0)
            maker.height(200)
        }
        
        view3.configureFrame { maker in
            maker.size(width: 30, height: 20)
            maker.centerY(between: view1, view2)
            maker.centerX()
        }
        
        XCTAssertEqual(view3.frame, CGRect(x: 235, y: 190, width: 30, height: 20))

        view3.frame = .zero
        view3.configureFrame { maker in
            maker.size(width: 30, height: 20)
            maker.centerY(between: view2, view1)
            maker.centerX()
        }

        XCTAssertEqual(view3.frame, CGRect(x: 235, y: 190, width: 30, height: 20))
    }

    /* super centerX without superview for related view */
    
    func testThatCorrectlyConfigures_centerX_forRelativelySuperViewWithoutOwnSuperView() {
    
        nestedView1.removeFromSuperview()
        
        let width: CGFloat = 10.0
        let height: CGFloat = 10.0
        nestedView2.frame = CGRect(x: 0, y: 0, width: width, height: height)
        nestedView2.configureFrame { maker in
            maker.centerX()
        }
        XCTAssertEqual(nestedView2.frame, CGRect(x: nestedView1.bounds.width/2.0 - CGFloat(width/2),
                                                 y: 0.0,
                                                 width: width,
                                                 height: height))
    }
    
    
    func testThatCorrectlyConfigures_centerX_forRelativelySuperViewWithoutOwnSuperViewWith_nonZeroOffset() {
        
        nestedView1.removeFromSuperview()
        
        let width: CGFloat = 10.0
        let height: CGFloat = 10.0
        let offset: CGFloat = 5.0
        
        nestedView2.frame = CGRect(x: 0, y: 0, width: width, height: height)
        nestedView2.configureFrame { maker in
            maker.centerX(offset: offset)
        }
        XCTAssertEqual(nestedView2.frame, CGRect(x: nestedView1.bounds.width/2.0 - CGFloat(width/2) - offset,
                                                 y: 0.0,
                                                 width: width,
                                                 height: height))
    }
    
    /* super centerY without superview for related view */
    
    func testThatCorrectlyConfigures_centerY_forRelativelySuperViewWithoutOwnSuperView() {
        
        nestedView1.removeFromSuperview()
        
        let width: CGFloat = 10.0
        let height: CGFloat = 10.0
        nestedView2.frame = CGRect(x: 0, y: 0, width: width, height: height)
        nestedView2.configureFrame { maker in
            maker.centerY()
        }
        XCTAssertEqual(nestedView2.frame, CGRect(x: 0.0,
                                                 y: nestedView1.bounds.height/2.0 - CGFloat(height/2),
                                                 width: width,
                                                 height: height))
    }
    
    
    func testThatCorrectlyConfigures_centerY_forRelativelySuperViewWithoutOwnSuperViewWith_nonZeroOffset() {
        
        nestedView1.removeFromSuperview()
        
        let width: CGFloat = 10.0
        let height: CGFloat = 10.0
        let offset: CGFloat = 5.0
        nestedView2.frame = CGRect(x: 0, y: 0, width: width, height: height)
        nestedView2.configureFrame { maker in
            maker.centerY(offset: offset)
        }
        XCTAssertEqual(nestedView2.frame, CGRect(x: 0.0,
                                                 y: nestedView1.bounds.height/2.0 - CGFloat(height/2) - offset,
                                                 width: width,
                                                 height: height))
    }
    
    /* super centerX */
    
    func testThatCorrectlyConfigures_centerX_forRelativelySuperViewWith_zeroOffset() {
        
        testingView.configureFrame { maker in
            maker.centerX()
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 225, y: 0, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_centerX_forRelativelySuperViewWith_nonZeroOffset() {
        
        testingView.configureFrame { maker in
            maker.centerX(offset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 215, y: 0, width: 50, height: 50))
    }
    
    
    /* super centerY */
    
    func testThatCorrectlyConfigures_centerY_forRelativelySuperViewWith_zeroOffset() {
        
        testingView.configureFrame { maker in
            maker.centerY()
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 225, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_centerY_forRelativelySuperViewWith_nonZeroOffset() {
        
        testingView.configureFrame { maker in
            maker.centerY(offset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 215, width: 50, height: 50))
    }
    
    
    /* centerX with nui_left */
    
    func testThatCorrectlyConfigures_centerX_withAnotherView_left_relationWith_zeroOffset() {
        
        testingView.configureFrame { maker in
            maker.centerX(to: nestedView2.nui_left)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 125, y: 0, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_centerX_withAnotherView_left_relationWith_nonZeroOffset() {
        
        testingView.configureFrame { maker in
            maker.centerX(to: nestedView2.nui_left, offset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 115, y: 0, width: 50, height: 50))
    }
    
    /* centerX with nui_centerX */
    
    func testThatCorrectlyConfigures_centerX_withAnotherView_centerX_relationWith_zeroOffset() {
        
        testingView.configureFrame { maker in
            maker.centerX(to: nestedView2.nui_centerX)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 225, y: 0, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_centerX_withAnotherView_centerX_relationWith_nonZeroOffset() {
        
        testingView.configureFrame { maker in
            maker.centerX(to: nestedView2.nui_centerX, offset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 215, y: 0, width: 50, height: 50))
    }
    
    /* centerX with nui_right */
    
    func testThatCorrectlyConfigures_centerX_withAnotherView_right_relationWith_zeroOffset() {
        
        testingView.configureFrame { maker in
            maker.centerX(to: nestedView2.nui_right)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 325, y: 0, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_centerX_withAnotherView_right_relationWith_nonZeroOffset() {
        
        testingView.configureFrame { maker in
            maker.centerX(to: nestedView2.nui_right, offset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 315, y: 0, width: 50, height: 50))
    }
    
    
    /* centerY with nui_top */
    
    func testThatCorrectlyConfigures_centerY_withAnotherView_top_relationWith_zeroOffset() {
        
        testingView.configureFrame { maker in
            maker.centerY(to: nestedView2.nui_top)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 125, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_centerY_withAnotherView_top_relationWith_nonZeroOffset() {
        
        testingView.configureFrame { maker in
            maker.centerY(to: nestedView2.nui_top, offset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 115, width: 50, height: 50))
    }
    
    /* centerY with nui_centerY */
    
    func testThatCorrectlyConfigures_centerY_withAnotherView_centerY_relationWith_zeroOffset() {
        
        testingView.configureFrame { maker in
            maker.centerY(to: nestedView2.nui_centerY)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 225, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_centerY_withAnotherView_centerY_relationWith_nonZeroOffset() {
        
        testingView.configureFrame { maker in
            maker.centerY(to: nestedView2.nui_centerY, offset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 215, width: 50, height: 50))
    }
    
    /* centerY with nui_bottom */
    
    func testThatCorrectlyConfigures_centerY_withAnotherView_bottom_relationWith_zeroOffset() {
        
        testingView.configureFrame { maker in
            maker.centerY(to: nestedView2.nui_bottom)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 325, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_centerY_withAnotherView_bottom_relationWith_nonZeroOffset() {
        
        testingView.configureFrame { maker in
            maker.centerY(to: nestedView2.nui_bottom, offset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 315, width: 50, height: 50))
    }
    
    
    /* just setting centerX and centerY*/
    
    func testThatCorrectlyConfiguresSettingValueForCenterYAndCenterX() {
        
        testingView.configureFrame { maker in
            maker.setCenterX(value: 30)
            maker.setCenterY(value: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 5, y: -15, width: 50, height: 50))
    }
    
    /* center(x and y) */
    
    func testThatCorrectlyConfiguresCenterToSuperview() {
        
        testingView.configureFrame { maker in
            maker.center()
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 225, y: 225, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfiguresCenterToAnotherView() {
        
        testingView.configureFrame { maker in
            maker.center(to: nestedView2)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 225, y: 225, width: 50, height: 50))
    }
}

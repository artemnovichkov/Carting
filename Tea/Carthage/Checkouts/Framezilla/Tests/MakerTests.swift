//
//  MakerTests.swift
//  Framezilla
//
//  Created by Nikita on 06/09/16.
//  Copyright © 2016 Nikita. All rights reserved.
//

import XCTest

class MakerTests: BaseTest {
    
    /* Array configurator */
    
    func testThatCorrectlyConfiguresFramesForArrayOfViews() {
        
        let label = UILabel(frame: .zero)
        let view = UIView(frame: .zero)
        
        [label, view].configureFrames { maker in
            maker.width(100)
            maker.height(50)
        }
        XCTAssertEqual(label.frame, CGRect(x: 0, y: 0, width: 100, height: 50))
        XCTAssertEqual(view.frame, CGRect(x: 0, y: 0, width: 100, height: 50))
    }
    
    /* bottom_to with nui_top */
    
    func testThatCorrectlyConfigures_bottom_to_withAnotherView_top_relationWith_zeroInset() {
        
        testingView.configureFrame { maker in
            maker.bottom(to: nestedView2.nui_top)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 100, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_bottom_to_withAnotherView_top_relationWith_nonZeroInset() {
        
        testingView.configureFrame { maker in
            maker.bottom(to: nestedView2.nui_top, inset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 90, width: 50, height: 50))
    }
    
    /* bottom_to with nui_centerY */
    
    func testThatCorrectlyConfigures_bottom_to_withAnotherView_centerY_relationWith_zeroInset() {
        
        testingView.configureFrame { maker in
            maker.bottom(to: nestedView2.nui_centerY)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 200, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_bottom_to_withAnotherView_centerY_relationWith_nonZeroInset() {
        
        testingView.configureFrame { maker in
            maker.bottom(to: nestedView2.nui_centerY, inset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 190, width: 50, height: 50))
    }
    
    /* bottom_to with nui_bottom */
    
    func testThatCorrectlyConfigures_bottom_to_withAnotherView_bottom_relationWith_zeroInset() {
        
        testingView.configureFrame { maker in
            maker.bottom(to: nestedView2.nui_bottom)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 300, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_bottom_to_withAnotherView_bottom_relationWith_nonZeroInset() {
        
        testingView.configureFrame { maker in
            maker.bottom(to: nestedView2.nui_bottom, inset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 290, width: 50, height: 50))
    }
    
    
    
    /* top_to with nui_top */
    
    func testThatCorrectlyConfigures_top_to_withAnotherView_top_relationWith_zeroInset() {
        
        testingView.configureFrame { maker in
            maker.top(to: nestedView2.nui_top)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 150, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_top_to_withAnotherView_top_relationWith_nonZeroInset() {
        
        testingView.configureFrame { maker in
            maker.top(to: nestedView2.nui_top, inset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 160, width: 50, height: 50))
    }
    
    /* top_to with nui_centerY */
    
    func testThatCorrectlyConfigures_top_to_withAnotherView_centerY_relationWith_zeroInset() {
        
        testingView.configureFrame { maker in
            maker.top(to: nestedView2.nui_centerY)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 250, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_top_to_withAnotherView_centerY_relationWith_nonZeroInset() {
        
        testingView.configureFrame { maker in
            maker.top(to: nestedView2.nui_centerY, inset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 260, width: 50, height: 50))
    }
    
    /* top_to with nui_bottom */
    
    func testThatCorrectlyConfigures_top_to_withAnotherView_bottom_relationWith_zeroInset() {
        
        testingView.configureFrame { maker in
            maker.top(to: nestedView2.nui_bottom)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 350, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_top_to_withAnotherView_bottom_relationWith_nonZeroInset() {
        
        testingView.configureFrame { maker in
            maker.top(to: nestedView2.nui_bottom, inset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 360, width: 50, height: 50))
    }
    
    
    
    /* right_to with nui_right */
    
    func testThatCorrectlyConfigures_right_to_withAnotherView_right_relationWith_zeroInset() {
        
        testingView.configureFrame { maker in
            maker.right(to: nestedView2.nui_right)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 300, y: 0, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_right_to_withAnotherView_right_relationWith_nonZeroInset() {
        
        testingView.configureFrame { maker in
            maker.right(to: nestedView2.nui_right, inset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 290, y: 0, width: 50, height: 50))
    }
    
    /* top_to with nui_centerX */
    
    func testThatCorrectlyConfigures_right_to_withAnotherView_centerX_relationWith_zeroInset() {
        
        testingView.configureFrame { maker in
            maker.right(to: nestedView2.nui_centerX)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 200, y: 0, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_right_to_withAnotherView_centerX_relationWith_nonZeroInset() {
        
        testingView.configureFrame { maker in
            maker.right(to: nestedView2.nui_centerX, inset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 190, y: 0, width: 50, height: 50))
    }
    
    /* top_to with nui_left */
    
    func testThatCorrectlyConfigures_right_to_withAnotherView_left_relationWith_zeroInset() {
        
        testingView.configureFrame { maker in
            maker.right(to: nestedView2.nui_left)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 100, y: 0, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_right_to_withAnotherView_left_relationWith_nonZeroInset() {
        
        testingView.configureFrame { maker in
            maker.right(to: nestedView2.nui_left, inset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 90, y: 0, width: 50, height: 50))
    }
    
    
    
    /* left_to with nui_right */
    
    func testThatCorrectlyConfigures_left_to_withAnotherView_right_relationWith_zeroInset() {
        
        testingView.configureFrame { maker in
            maker.left(to: nestedView2.nui_right)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 350, y: 0, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_left_to_withAnotherView_right_relationWith_nonZeroInset() {
        
        testingView.configureFrame { maker in
            maker.left(to: nestedView2.nui_right, inset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 360, y: 0, width: 50, height: 50))
    }
    
    /* left_to with nui_centerX */
    
    func testThatCorrectlyConfigures_left_to_withAnotherView_centerX_relationWith_zeroInset() {
        
        testingView.configureFrame { maker in
            maker.left(to: nestedView2.nui_centerX)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 250, y: 0, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_left_to_withAnotherView_centerX_relationWith_nonZeroInset() {
        
        testingView.configureFrame { maker in
            maker.left(to: nestedView2.nui_centerX, inset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 260, y: 0, width: 50, height: 50))
    }
    
    /* left_to with nui_left */
    
    func testThatCorrectlyConfigures_left_to_withAnotherView_left_relationWith_zeroInset() {
        
        testingView.configureFrame { maker in
            maker.left(to: nestedView2.nui_left)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 150, y: 0, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_left_to_withAnotherView_left_relationWith_nonZeroInset() {
        
        testingView.configureFrame { maker in
            maker.left(to: nestedView2.nui_left, inset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 160, y: 0, width: 50, height: 50))
    }
    
    
    
    /* left to superview */
    
    func testThatCorrectlyConfigures_left_toSuperviewWith_zeroInset() {
        
        testingView.configureFrame { maker in
            maker.left()
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 0, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_left_toSuperviewWith_nonZeroInset() {
        
        testingView.configureFrame { maker in
            maker.left(inset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 10, y: 0, width: 50, height: 50))
    }
    
    /* top to superview */
    
    func testThatCorrectlyConfigures_top_toSuperviewWith_zeroInset() {
        
        testingView.configureFrame { maker in
            maker.top()
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 0, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_top_toSuperviewWith_nonZeroInset() {
        
        testingView.configureFrame { maker in
            maker.top(inset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 10, width: 50, height: 50))
    }
    
    
    /* bottom to superview */
    
    func testThatCorrectlyConfigures_bottom_toSuperviewWith_zeroInset() {
        
        testingView.configureFrame { maker in
            maker.bottom()
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 450, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_bottom_toSuperviewWith_nonZeroInset() {
        
        testingView.configureFrame { maker in
            maker.bottom(inset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 440, width: 50, height: 50))
    }
    
    
    /* right to superview */
    
    func testThatCorrectlyConfigures_right_toSuperviewWith_zeroInset() {
        
        testingView.configureFrame { maker in
            maker.right()
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 450, y: 0, width: 50, height: 50))
    }
    
    func testThatCorrectlyConfigures_right_toSuperviewWith_nonZeroInset() {
        
        testingView.configureFrame { maker in
            maker.right(inset: 10)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 440, y: 0, width: 50, height: 50))
    }
    
    
    /* edges */
    
    func testThatCorrectlyConfigures_margin_relation() {
        
        let inset: CGFloat = 5
        testingView.configureFrame { maker in
            maker.margin(inset)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: inset, y: inset, width: 490, height: 490))
    }
    
    func testThatCorrectlyConfigures_equal_to_relationForNearSubview() {
        
        let insets = UIEdgeInsetsMake(5, 10, 15, 20)
        testingView.configureFrame { maker in
            maker.equal(to: nestedView1, insets: insets)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: nestedView1.frame.minX + insets.left,
                                                 y: nestedView1.frame.minY + insets.top,
                                                 width: nestedView1.bounds.width-(insets.left + insets.right),
                                                 height: nestedView1.bounds.height-(insets.top + insets.bottom)))
    }
    
    func testThatCorrectlyConfigures_equal_to_dependsOnSuperview() {
        testingView.configureFrame { maker in
            maker.equal(to: mainView)
        }
        XCTAssertEqual(testingView.frame, mainView.frame)
    }
    
    func testThatCorrectlyConfigures_edge_insets_toSuperview() {
        
        testingView.configureFrame { maker in
            maker.edges(insets: UIEdgeInsetsMake(10, 20, 40, 60))
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 20, y: 10, width: 420, height: 450))
    }
    
    func testThatCorrectlyConfigures_edge_toSuperview() {
        
        testingView.configureFrame { maker in
            maker.edges(top: 20, left: 20, bottom: 20, right: 20)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 20, y: 20, width: 460, height: 460))
    }
    
    /* container */
    
    func testThatCorrectlyConfiguresContainer() {
        
        let view1 = UIView(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        let view2 = UIView(frame: CGRect(x: 70, y: 70, width: 50, height: 50))
        
        let containet = UIView()
        containet.addSubview(view1)
        containet.addSubview(view2)
        
        containet.configureFrame { maker in
            maker._container()
        }
        XCTAssertEqual(containet.frame, CGRect(x: 0, y: 0, width: 120, height: 120))
    }
    
    /* sizeToFit */
    
    func testThat_sizeToFit_correctlyConfigures() {

        let label = UILabel()
        label.text = "Hello"
        
        label.configureFrame { maker in
            maker.sizeToFit()
        }
        XCTAssertGreaterThan(label.bounds.width, 0)
        XCTAssertGreaterThan(label.bounds.height, 0)
    }
    
    /* sizeThatFits */
    
    func testThat_sizeThatFits_correctlyConfigures() {
        
        let label = UILabel()
        label.text = "HelloHelloHelloHello"
        
        label.configureFrame { maker in
            maker.sizeThatFits(size: CGSize(width: 30, height: 0))
        }
        XCTAssertEqual(label.bounds.width, 30)
        XCTAssertEqual(label.bounds.height, 0)
    }

    /* corner radius */

    func testThat_cornerRadius_correctlyConfigures() {
        let view = UIView()

        view.configureFrame { maker in
            maker.cornerRadius(100)
        }
        XCTAssertEqual(view.layer.cornerRadius, 100)
    }

    func testThat_cornerRadiusWithHalfWidth_correctlyConfigures() {
        let view = UIView()

        view.configureFrame { maker in
            maker.width(100)
            maker.cornerRadius(byHalf: .width)
        }
        XCTAssertEqual(view.layer.cornerRadius, 50)
    }

    func testThat_cornerRadiusWithHalfHeight_correctlyConfigures() {
        let view = UIView()

        view.configureFrame { maker in
            maker.height(100)
            maker.cornerRadius(byHalf: .height)
        }
        XCTAssertEqual(view.layer.cornerRadius, 50)
    }
}

//
//  MakerWidthHeightTests.swift
//  Framezilla
//
//  Created by Nikita on 06/09/16.
//  Copyright © 2016 Nikita. All rights reserved.
//

import XCTest
@testable import Framezilla

final class HeightFitView: UIView {

    let maxHeight: CGFloat = 100
    let middleHeight: CGFloat = 70
    let lowHeight: CGFloat = 50

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        if size.width > 100 {
            return CGSize(width: size.width, height: maxHeight)
        }
        else if size.width < 50 {
            return CGSize(width: size.width, height: lowHeight)
        }
        return CGSize(width: size.width, height: middleHeight)
    }
}

final class WidthFitView: UIView {

    let maxWidth: CGFloat = 100
    let middleWidth: CGFloat = 70
    let lowWidth: CGFloat = 50

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        if size.height > 100 {
            return CGSize(width: maxWidth, height: size.height)
        }
        else if size.height < 50 {
            return CGSize(width: lowWidth, height: size.width)
        }
        return CGSize(width: middleWidth, height: size.width)
    }
}

class MakerWidthHeightTests: BaseTest {
    
    func testThatJustSetting_width_configuresCorrectly() {
        
        testingView.configureFrame { maker in
            maker.width(400)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 0, width: 400, height: 50))
    }
    
    func testThatJustSetting_height_configuresCorrectly() {
        
        testingView.configureFrame { maker in
            maker.height(400)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 0, width: 50, height: 400))
    }
    
    /* size */
    
    func testThat_size_configuresCorrectly() {
        
        testingView.configureFrame { maker in
            maker.size(width: 100, height: 99)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 0, width: 100, height: 99))
    }
    
    /* with_to */
    
    func testThat_width_to_toAnotherView_width_configuresCorrectly() {
        
        testingView.configureFrame { maker in
            maker.width(to: nestedView2.nui_width, multiplier: 0.5)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 0, width: 100, height: 50))
    }
    
    func testThat_width_to_toAnotherView_height_configuresCorrectly() {
        
        testingView.configureFrame { maker in
            maker.width(to: nestedView2.nui_height, multiplier: 1)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 0, width: 200, height: 50))
    }
    
    func testThat_width_to_toSelfView_height_configuresCorrectlyWithTopAndBottomSuperViewRelations() {
        
        testingView.configureFrame { maker in
            maker.top(inset: 10)
            maker.bottom(inset: 10)
            maker.width(to: testingView.nui_height, multiplier: 0.5)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 10, width: 240, height: 480))
    }
    
    func testThat_width_to_toSelfView_height_configuresCorrectlyWithTopAndBottomAnotherViewsRelations() {
        
        testingView.configureFrame { maker in
            maker.top(to: nestedView2.nui_top, inset: 10)
            maker.bottom(to: nestedView1.nui_bottom, inset: 10)
            maker.width(to: testingView.nui_height, multiplier: 0.5)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 160, width: 115, height: 230))
    }
    
    func testThat_width_to_configuresCorrectlyWithJustSettingHeight() {
        
        testingView.configureFrame { maker in
            maker.height(100)
            maker.width(to: testingView.nui_height, multiplier: 0.5)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 0, width: 50, height: 100))
    }
    
    /* height_to */
    
    func testThat_height_to_toAnotherView_width_configuresCorrectly() {
        
        testingView.configureFrame { maker in
            maker.height(to: nestedView2.nui_width, multiplier: 0.5)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 0, width: 50, height: 100))
    }
    
    func testThat_height_to_toAnotherView_height_configuresCorrectly() {
        
        testingView.configureFrame { maker in
            maker.height(to: nestedView2.nui_height, multiplier: 1)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 0, width: 50, height: 200))
    }
    
    func testThat_height_to_toSelfView_width_configuresCorrectlyWithLeftAndRightSuperViewRelations() {
        
        testingView.configureFrame { maker in
            maker.right(inset: 10)
            maker.left(inset: 10)
            maker.height(to: testingView.nui_width, multiplier: 0.5)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 10, y: 0, width: 480, height: 240))
    }
    
    func testThat_height_to_toSelfView_width_configuresCorrectlyWithLeftAndRightAnotherViewsRelations() {
        
        testingView.configureFrame { maker in
            maker.right(to: nestedView1.nui_right, inset: 10)
            maker.left(to: nestedView1.nui_left, inset: 10)
            maker.height(to: testingView.nui_width, multiplier: 0.5)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 110, y: 0, width: 280, height: 140))
    }
    
    func testThat_height_to_configuresCorrectlyWithJustSettingWidth() {
        
        testingView.configureFrame { maker in
            maker.width(100)
            maker.height(to: testingView.nui_width, multiplier: 0.5)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 0, y: 0, width: 100, height: 50))
    }
    
    /* height_to with width_to */
    
    func testThat_height_to_correctlyConfiguresWithAnotherViewWidthAnd_width_to_toMyselfHeightRelation() {
        
        testingView.configureFrame { maker in
            maker.centerX()
            maker.centerY()
            maker.height(to: mainView.nui_width, multiplier: 0.5)
            maker.width(to: testingView.nui_height, multiplier: 0.5)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 187.5, y: 125, width: 125, height: 250))
    }
    
    func testThat_width_to_correctlyConfiguresWithAnotherViewHeightAnd_height_to_toMyselfWidthRelation() {
        
        testingView.configureFrame { maker in
            maker.centerX()
            maker.centerY()
            maker.width(to: mainView.nui_height, multiplier: 0.5)
            maker.height(to: testingView.nui_width, multiplier: 0.5)
        }
        XCTAssertEqual(testingView.frame, CGRect(x: 125, y: 187.5, width: 250, height: 125))
    }

    /* width / height to fit */

    func testHeightToFit() {

        let label = UILabel()
        label.text = "HelloHelloHelloHello"

        label.configureFrame { maker in
            maker.heightToFit()
        }
        XCTAssertTrue(label.bounds.height > 0)
        XCTAssertEqual(label.bounds.width, 0)
    }

    func testHeightToFit_withWidthRelation() {

        let view = HeightFitView()

        view.configureFrame { maker in
            maker.heightToFit()
            maker.width(120)
        }
        XCTAssertEqual(view.frame, CGRect(x: 0, y: 0, width: 120, height: view.maxHeight))
    }

    func testHeightToFit_withLeftAndRightRelations() {

        let view = HeightFitView()
        mainView.addSubview(view)

        view.configureFrame { maker in
            maker.heightToFit()
            maker.left(inset: 220).right(inset: 220)
            maker.top()
        }
        XCTAssertEqual(view.frame, CGRect(x: 220, y: 0, width: 60, height: view.middleHeight))
        view.removeFromSuperview()
    }

    func testHeightToFit_withWidthToRelation() {

        let view = HeightFitView()
        mainView.addSubview(view)

        view.configureFrame { maker in
            maker.heightToFit()
            maker.width(to: mainView.nui_width, multiplier: 0.01)
            maker.top()
        }
        XCTAssertEqual(view.frame, CGRect(x: 0, y: 0, width: 5, height: view.lowHeight))
        view.removeFromSuperview()
    }

    func testWidthToFit() {

        let label = UILabel()
        label.text = "HelloHelloHelloHello"

        label.configureFrame { maker in
            maker.widthToFit()
        }
        XCTAssertTrue(label.bounds.width > 0)
        XCTAssertEqual(label.bounds.height, 0)
    }

    func testWidthToFit_withHeightRelation() {

        let view = WidthFitView()

        view.configureFrame { maker in
            maker.widthToFit()
            maker.height(120)
        }
        XCTAssertEqual(view.frame, CGRect(x: 0, y: 0, width: view.maxWidth, height: 120))
    }

    func testWidthToFit_withTopAndBottomRelations() {

        let view = WidthFitView()
        mainView.addSubview(view)

        view.configureFrame { maker in
            maker.widthToFit()
            maker.top(inset: 220).bottom(inset: 220)
            maker.left()
        }
        XCTAssertEqual(view.frame, CGRect(x: 0, y: 220, width: view.middleWidth, height: 60))
        view.removeFromSuperview()
    }

    func testWidthToFit_withHeightToRelation() {

        let view = WidthFitView()
        mainView.addSubview(view)

        view.configureFrame { maker in
            maker.widthToFit()
            maker.height(to: mainView.nui_width, multiplier: 0.01)
            maker.left()
        }
        XCTAssertEqual(view.frame, CGRect(x: 0, y: 0, width: view.lowWidth, height: 5))
        view.removeFromSuperview()
    }

    /* width / height that fits */

    func testThat_widthThatFits_correctlyConfiguresRelativeLowMaxWidth() {

        let label = UILabel()
        label.text = "HelloHelloHelloHello"

        label.configureFrame { maker in
            maker.widthThatFits(maxWidth: 30)
        }
        XCTAssertEqual(label.bounds.width, 30)
        XCTAssertEqual(label.bounds.height, 0)
    }

    func testThat_widthThatFits_correctlyConfiguresRelativeHighMaxWidth() {

        let label = UILabel()
        label.text = "HelloHelloHelloHello"

        label.configureFrame { maker in
            maker.widthThatFits(maxWidth: 300)
        }
        XCTAssertTrue(label.bounds.width != 300)
        XCTAssertEqual(label.bounds.height, 0)
    }

    func testThat_heightThatFits_correctlyConfiguresRelativeLowMaxHeight() {

        let label = UILabel()
        label.text = "HelloHelloHelloHello"

        label.configureFrame { maker in
            maker.heightThatFits(maxHeight: 5)
        }
        XCTAssertEqual(label.bounds.height, 5)
        XCTAssertEqual(label.bounds.width, 0)
    }

    func testThat_heightThatFits_correctlyConfiguresRelativeHighMaxHeight() {

        let label = UILabel()
        label.text = "HelloHelloHelloHello"

        label.configureFrame { maker in
            maker.heightThatFits(maxHeight: 300)
        }
        XCTAssertTrue(label.bounds.height != 300)
        XCTAssertEqual(label.bounds.width, 0)
    }
}

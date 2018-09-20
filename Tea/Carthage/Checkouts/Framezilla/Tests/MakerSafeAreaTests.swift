//
//  MakerSafeAreaTests.swift
//  FramezillaTests
//
//  Created by Nikita Ermolenko on 21/10/2017.
//

import XCTest
import Framezilla

class MakerSafeAreaTests: XCTestCase {
    
    private let viewController = UIViewController()
    
    override func setUp() {
        super.setUp()
        viewController.view.frame = CGRect(x: 0, y: 0, width: 300, height: 500)
        
        let window = UIWindow()
        window.rootViewController = viewController
        window.isHidden = false
    }
    
    override func tearDown() {
        if #available(iOS 11.0, *) {
            viewController.additionalSafeAreaInsets = .zero
        }
        super.tearDown()
    }
    
    /* top */
    
    func testThatCorrectlyConfigures_top_to_SafeArea() {
        if #available(iOS 11.0, *) {
            viewController.additionalSafeAreaInsets.top = 10
        }
        
        let view = UIView()
        viewController.view.addSubview(view)
        
        view.configureFrame { maker in
            maker.top(to: nui_safeArea)
            maker.left()
            maker.size(width: 20, height: 20)
        }
        
        if #available(iOS 11.0, *) {
            XCTAssertEqual(view.frame, CGRect(x: 0, y: viewController.additionalSafeAreaInsets.top, width: 20, height: 20))
        }
        else {
            XCTAssertEqual(view.frame, CGRect(x: 0, y: 0, width: 20, height: 20))
        }
    }
    
    func testThatCorrectlyConfigures_top_to_SafeAreaWithInset() {
        if #available(iOS 11.0, *) {
            viewController.additionalSafeAreaInsets.top = 10
        }
        
        let view = UIView()
        viewController.view.addSubview(view)
        
        let inset: CGFloat = 5
        view.configureFrame { maker in
            maker.top(to: nui_safeArea, inset: inset)
            maker.left()
            maker.size(width: 20, height: 20)
        }
        
        if #available(iOS 11.0, *) {
            XCTAssertEqual(view.frame, CGRect(x: 0, y: viewController.additionalSafeAreaInsets.top + inset, width: 20, height: 20))
        }
        else {
            XCTAssertEqual(view.frame, CGRect(x: 0, y: inset, width: 20, height: 20))
        }
    }
    
    /* left */
    
    func testThatCorrectlyConfigures_left_to_SafeArea() {
        if #available(iOS 11.0, *) {
            viewController.additionalSafeAreaInsets.left = 10
        }
        
        let view = UIView()
        viewController.view.addSubview(view)
        
        view.configureFrame { maker in
            maker.top()
            maker.left(to: nui_safeArea)
            maker.size(width: 20, height: 20)
        }
        
        if #available(iOS 11.0, *) {
            XCTAssertEqual(view.frame, CGRect(x: viewController.additionalSafeAreaInsets.left, y: 0, width: 20, height: 20))
        }
        else {
            XCTAssertEqual(view.frame, CGRect(x: 0, y: 0, width: 20, height: 20))
        }
    }
    
    func testThatCorrectlyConfigures_left_to_SafeAreaWithInset() {
        if #available(iOS 11.0, *) {
            viewController.additionalSafeAreaInsets.left = 10
        }
        
        let view = UIView()
        viewController.view.addSubview(view)
        
        let inset: CGFloat = 5
        view.configureFrame { maker in
            maker.top()
            maker.left(to: nui_safeArea, inset: inset)
            maker.size(width: 20, height: 20)
        }
        
        if #available(iOS 11.0, *) {
            XCTAssertEqual(view.frame, CGRect(x: viewController.additionalSafeAreaInsets.left + inset,
                                              y: 0,
                                              width: 20,
                                              height: 20))
        }
        else {
            XCTAssertEqual(view.frame, CGRect(x: inset,
                                              y: 0,
                                              width: 20,
                                              height: 20))
        }
    }
    
    /* bottom */
    
    func testThatCorrectlyConfigures_bottom_to_SafeArea() {
        if #available(iOS 11.0, *) {
            viewController.additionalSafeAreaInsets.bottom = 10
        }
        
        let view = UIView()
        viewController.view.addSubview(view)
        
        view.configureFrame { maker in
            maker.bottom(to: nui_safeArea)
            maker.left()
            maker.size(width: 20, height: 20)
        }
        
        if #available(iOS 11.0, *) {
            XCTAssertEqual(view.frame, CGRect(x: 0,
                                              y: viewController.view.frame.height - viewController.additionalSafeAreaInsets.bottom - 20,
                                              width: 20,
                                              height: 20))
        }
        else {
            XCTAssertEqual(view.frame, CGRect(x: 0,
                                              y: viewController.view.frame.height - 20,
                                              width: 20,
                                              height: 20))
        }
    }
    
    func testThatCorrectlyConfigures_bottom_to_SafeAreaWithInset() {
        if #available(iOS 11.0, *) {
            viewController.additionalSafeAreaInsets.bottom = 10
        }
        
        let view = UIView()
        viewController.view.addSubview(view)
        
        let inset: CGFloat = 5
        view.configureFrame { maker in
            maker.bottom(to: nui_safeArea, inset: inset)
            maker.left()
            maker.size(width: 20, height: 20)
        }
        
        if #available(iOS 11.0, *) {
            XCTAssertEqual(view.frame, CGRect(x: 0,
                                              y: viewController.view.frame.height - viewController.additionalSafeAreaInsets.bottom - 20 - inset,
                                              width: 20,
                                              height: 20))
        }
        else {
            XCTAssertEqual(view.frame, CGRect(x: 0,
                                              y: viewController.view.frame.height - 20 - inset,
                                              width: 20,
                                              height: 20))
        }
    }
    
    /* right */
    
    func testThatCorrectlyConfigures_right_to_SafeArea() {
        if #available(iOS 11.0, *) {
            viewController.additionalSafeAreaInsets.right = 10
        }
        
        let view = UIView()
        viewController.view.addSubview(view)
        
        view.configureFrame { maker in
            maker.right(to: nui_safeArea)
            maker.bottom()
            maker.size(width: 20, height: 20)
        }
        
        if #available(iOS 11.0, *) {
            XCTAssertEqual(view.frame, CGRect(x: viewController.view.frame.width - viewController.additionalSafeAreaInsets.right - 20,
                                              y: viewController.view.frame.height - 20,
                                              width: 20,
                                              height: 20))
        }
        else {
            XCTAssertEqual(view.frame, CGRect(x: viewController.view.frame.width - 20,
                                              y: viewController.view.frame.height - 20,
                                              width: 20,
                                              height: 20))
        }
    }
    
    func testThatCorrectlyConfigures_right_to_SafeAreaWithInset() {
        if #available(iOS 11.0, *) {
            viewController.additionalSafeAreaInsets.right = 10
        }
        
        let view = UIView()
        viewController.view.addSubview(view)
        
        let inset: CGFloat = 5
        view.configureFrame { maker in
            maker.right(to: nui_safeArea, inset: inset)
            maker.bottom()
            maker.size(width: 20, height: 20)
        }
        
        if #available(iOS 11.0, *) {
            XCTAssertEqual(view.frame, CGRect(x: viewController.view.frame.width - viewController.additionalSafeAreaInsets.right - 20 - inset,
                                              y: viewController.view.frame.height - 20,
                                              width: 20,
                                              height: 20))
        }
        else {
            XCTAssertEqual(view.frame, CGRect(x: viewController.view.frame.width - 20 - inset,
                                              y: viewController.view.frame.height - 20,
                                              width: 20,
                                              height: 20))
        }
    }
}

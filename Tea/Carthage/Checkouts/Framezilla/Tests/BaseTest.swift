//
//  BaseTest.swift
//  Framezilla
//
//  Created by Nikita on 06/09/16.
//  Copyright © 2016 Nikita. All rights reserved.
//

import XCTest

class BaseTest: XCTestCase {
    
    var mainView = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
    var nestedView1 = UIView(frame: CGRect(x: 100, y: 100, width: 300, height: 300))
    var nestedView2 = UIView(frame: CGRect(x: 50, y: 50, width: 200, height: 200))

    var testingView = UIView()
    
    override func setUp() {
        super.setUp()
        
        mainView.addSubview(nestedView1)
        mainView.addSubview(testingView)
        nestedView1.addSubview(nestedView2)
        
        testingView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    }
    
    override func tearDown() {
        super.tearDown()
        
        nestedView1.removeFromSuperview()
        nestedView2.removeFromSuperview()
        testingView.removeFromSuperview()
    }
}

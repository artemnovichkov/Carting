//
//  ContainerTests.swift
//  FramezillaTests
//
//  Created by Nikita Ermolenko on 26/12/2017.
//

import XCTest
import Framezilla

class ContainerTests: BaseTest {

    func testContainerConfigurationFromTopToBottom() {
        let content1 = UIView()
        let content2 = UIView()
        let content3 = UIView()
        let content4 = UIView()

        let container = [content1, content2, content3, content4].container(in: mainView) {
            content1.configureFrame { maker in
                maker.centerX()
                maker.top()
                maker.size(width: 50, height: 50)
            }

            content2.configureFrame { maker in
                maker.top(to: content1.nui_bottom, inset: 5)
                maker.left()
                maker.size(width: 80, height: 80)
            }

            content3.configureFrame { maker in
                maker.top(to: content1.nui_bottom, inset: 15)
                maker.left(to: content2.nui_right, inset: 5)
                maker.size(width: 80, height: 80)
            }

            content4.configureFrame { maker in
                maker.top(to: content3.nui_bottom, inset: 5)
                maker.right()
                maker.size(width: 20, height: 20)
            }
        }

        XCTAssertEqual(container.frame, CGRect(x: 0, y: 0, width: 165, height: 170))
        XCTAssertEqual(content1.frame, CGRect(x: 57.5, y: 0, width: 50, height: 50))
        XCTAssertEqual(content2.frame, CGRect(x: 0, y: 55, width: 80, height: 80))
        XCTAssertEqual(content3.frame, CGRect(x: 85, y: 65, width: 80, height: 80))
        XCTAssertEqual(content4.frame, CGRect(x: 145, y: 150, width: 20, height: 20))
    }

    func testContainerConfigurationFromLeftToRight() {
        let content1 = UIView()
        let content2 = UIView()
        let content3 = UIView()

        let container = [content1, content2, content3].container(in: mainView) {
            content1.configureFrame { maker in
                maker.left()
                maker.centerY()
                maker.size(width: 50, height: 50)
            }

            content2.configureFrame { maker in
                maker.left(to: content1.nui_right, inset: 5)
                maker.centerY()
                maker.size(width: 30, height: 140)
            }

            content3.configureFrame { maker in
                maker.left(to: content2.nui_right, inset: 15)
                maker.centerY()
                maker.size(width: 80, height: 80)
            }
        }

        XCTAssertEqual(container.frame, CGRect(x: 0, y: 0, width: 180, height: 140))
        XCTAssertEqual(content1.frame, CGRect(x: 0, y: 45, width: 50, height: 50))
        XCTAssertEqual(content2.frame, CGRect(x: 55, y: 0, width: 30, height: 140))
        XCTAssertEqual(content3.frame, CGRect(x: 100, y: 30, width: 80, height: 80))
    }

    func testContainerConfigurationWithCenterYRelation() {
        let content1 = UIView()
        let content2 = UIView()

        let container = [content1, content2].container(in: mainView) {
            content1.configureFrame { maker in
                maker.top(inset: 10)
                maker.centerX()
                maker.size(width: 180, height: 50)
            }

            content2.configureFrame { maker in
                maker.top(to: content1.nui_bottom, inset: 10)
                maker.left()
                maker.size(width: 250, height: 200)
            }
        }

        XCTAssertEqual(container.frame, CGRect(x: 0, y: 0, width: 250, height: 270))
        XCTAssertEqual(content1.frame, CGRect(x: 35, y: 10, width: 180, height: 50))
        XCTAssertEqual(content2.frame, CGRect(x: 0, y: 70, width: 250, height: 200))
    }

    func testContainerConfigurationWithCenterXRelation() {
        let content1 = UIView()
        let content2 = UIView()

        let container = [content1, content2].container(in: mainView) {
            content2.configureFrame { maker in
                maker.top().left(inset: 10)
                maker.size(width: 200, height: 250)
            }

            content1.configureFrame { maker in
                maker.left(to: content2.nui_right, inset: 10)
                maker.centerY()
                maker.size(width: 50, height: 180)
            }
        }

        XCTAssertEqual(container.frame, CGRect(x: 0, y: 0, width: 270, height: 250))
        XCTAssertEqual(content1.frame, CGRect(x: 220, y: 35, width: 50, height: 180))
        XCTAssertEqual(content2.frame, CGRect(x: 10, y: 0, width: 200, height: 250))
    }

    func testContainerConfigurationWithStaticWidth() {
        let content1 = UIView()
        let content2 = UIView()
        let content3 = UIView()
        let content4 = UIView()

        let container = [content1, content2, content3, content4].container(in: mainView, relation: .width(200)) {
            content1.configureFrame { maker in
                maker.top(inset: 10)
                maker.size(width: 100, height: 60)
                maker.centerX()
            }

            content2.configureFrame { maker in
                maker.left().right().top(to: content1.nui_bottom, inset: 10)
                maker.height(50)
            }

            content3.configureFrame { maker in
                maker.left().right().top(to: content2.nui_bottom, inset: 10)
                maker.height(70)
            }

            content4.configureFrame { maker in
                maker.top(to: content3.nui_bottom, inset: 20)
                maker.size(width: 30, height: 30)
                maker.centerX()
            }
        }

        XCTAssertEqual(container.frame, CGRect(x: 0, y: 0, width: 200, height: 260))
        XCTAssertEqual(content1.frame, CGRect(x: 50, y: 10, width: 100, height: 60))
        XCTAssertEqual(content2.frame, CGRect(x: 0, y: 80, width: 200, height: 50))
        XCTAssertEqual(content3.frame, CGRect(x: 0, y: 140, width: 200, height: 70))
        XCTAssertEqual(content4.frame, CGRect(x: 85, y: 230, width: 30, height: 30))
    }

    func testContainerConfigurationWithStaticHeight() {
        let content1 = UIView()
        let content2 = UIView()
        let content3 = UIView()
        let content4 = UIView()

        let container = [content1, content2, content3, content4].container(in: mainView, relation: .height(200)) {
            content1.configureFrame { maker in
                maker.left(inset: 10)
                maker.size(width: 60, height: 100)
                maker.centerY()
            }

            content2.configureFrame { maker in
                maker.top().bottom().left(to: content1.nui_right, inset: 10)
                maker.width(50)
            }

            content3.configureFrame { maker in
                maker.top().bottom().left(to: content2.nui_right, inset: 10)
                maker.width(70)
            }

            content4.configureFrame { maker in
                maker.left(to: content3.nui_right, inset: 20)
                maker.size(width: 30, height: 30)
                maker.centerY()
            }
        }

        XCTAssertEqual(container.frame, CGRect(x: 0, y: 0, width: 260, height: 200))
        XCTAssertEqual(content1.frame, CGRect(x: 10, y: 50, width: 60, height: 100))
        XCTAssertEqual(content2.frame, CGRect(x: 80, y: 0, width: 50, height: 200))
        XCTAssertEqual(content3.frame, CGRect(x: 140, y: 0, width: 70, height: 200))
        XCTAssertEqual(content4.frame, CGRect(x: 230, y: 85, width: 30, height: 30))
    }

    func testContainerConfigurationWithLeftAndRightRelations() {
        let content1 = UIView()
        let content2 = UIView()
        let content3 = UIView()
        let content4 = UIView()

        let container = [content1, content2, content3, content4].container(in: mainView, relation: .horizontal(left: 150, right: 150)) {
            content1.configureFrame { maker in
                maker.top(inset: 10)
                maker.size(width: 100, height: 60)
                maker.centerX()
            }

            content2.configureFrame { maker in
                maker.left().right().top(to: content1.nui_bottom, inset: 10)
                maker.height(50)
            }

            content3.configureFrame { maker in
                maker.left().right().top(to: content2.nui_bottom, inset: 10)
                maker.height(70)
            }

            content4.configureFrame { maker in
                maker.top(to: content3.nui_bottom, inset: 20)
                maker.size(width: 30, height: 30)
                maker.centerX()
            }
        }

        XCTAssertEqual(container.frame, CGRect(x: 0, y: 0, width: 200, height: 260))
        XCTAssertEqual(content1.frame, CGRect(x: 50, y: 10, width: 100, height: 60))
        XCTAssertEqual(content2.frame, CGRect(x: 0, y: 80, width: 200, height: 50))
        XCTAssertEqual(content3.frame, CGRect(x: 0, y: 140, width: 200, height: 70))
        XCTAssertEqual(content4.frame, CGRect(x: 85, y: 230, width: 30, height: 30))
    }

    func testContainerConfigurationWithTopAndBottomRelations() {
        let content1 = UIView()
        let content2 = UIView()
        let content3 = UIView()
        let content4 = UIView()

        let container = [content1, content2, content3, content4].container(in: mainView, relation: .vertical(top: 150, bottom: 150)) {
            content1.configureFrame { maker in
                maker.left(inset: 10)
                maker.size(width: 60, height: 100)
                maker.centerY()
            }

            content2.configureFrame { maker in
                maker.top().bottom().left(to: content1.nui_right, inset: 10)
                maker.width(50)
            }

            content3.configureFrame { maker in
                maker.top().bottom().left(to: content2.nui_right, inset: 10)
                maker.width(70)
            }

            content4.configureFrame { maker in
                maker.left(to: content3.nui_right, inset: 20)
                maker.size(width: 30, height: 30)
                maker.centerY()
            }
        }

        XCTAssertEqual(container.frame, CGRect(x: 0, y: 0, width: 260, height: 200))
        XCTAssertEqual(content1.frame, CGRect(x: 10, y: 50, width: 60, height: 100))
        XCTAssertEqual(content2.frame, CGRect(x: 80, y: 0, width: 50, height: 200))
        XCTAssertEqual(content3.frame, CGRect(x: 140, y: 0, width: 70, height: 200))
        XCTAssertEqual(content4.frame, CGRect(x: 230, y: 85, width: 30, height: 30))
    }
    
    func testContainerHaveConstantWidthWithLeftAndRightRelations() {
        let content1 = UIView()

        let container = [content1].container(in: mainView, relation: .horizontal(left: 50, right: 50)) {
            content1.configureFrame { maker in
                maker.top()
                maker.size(width: 500, height: 100)
            }
        }
        
        XCTAssertEqual(container.frame, CGRect(x: 0, y: 0, width: 400, height: 100))
        XCTAssertEqual(content1.frame, CGRect(x: 0, y: 0, width: 500, height: 100))
    }
    
    func testContainerHaveConstantWidthWithWidthRelation() {
        let content1 = UIView()
        
        let container = [content1].container(in: mainView, relation: .width(400)) {
            content1.configureFrame { maker in
                maker.top()
                maker.size(width: 500, height: 100)
            }
        }
        
        XCTAssertEqual(container.frame, CGRect(x: 0, y: 0, width: 400, height: 100))
        XCTAssertEqual(content1.frame, CGRect(x: 0, y: 0, width: 500, height: 100))
    }
    
    func testContainerHaveConstantHeightWithTopAndBottomRelations() {
        let content1 = UIView()
        
        let container = [content1].container(in: mainView, relation: .vertical(top: 50, bottom: 50)) {
            content1.configureFrame { maker in
                maker.top()
                maker.size(width: 100, height: 500)
            }
        }
        
        XCTAssertEqual(container.frame, CGRect(x: 0, y: 0, width: 100, height: 400))
        XCTAssertEqual(content1.frame, CGRect(x: 0, y: 0, width: 100, height: 500))
    }
    
    func testContainerHaveConstantHeightWithHeightRelation() {
        let content1 = UIView()
        
        let container = [content1].container(in: mainView, relation: .height(400)) {
            content1.configureFrame { maker in
                maker.top()
                maker.size(width: 100, height: 500)
            }
        }
        
        XCTAssertEqual(container.frame, CGRect(x: 0, y: 0, width: 100, height: 400))
        XCTAssertEqual(content1.frame, CGRect(x: 0, y: 0, width: 100, height: 500))
    }
}

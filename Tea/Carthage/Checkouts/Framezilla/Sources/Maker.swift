//
//  Maker.swift
//  Framezilla
//
//  Created by Nikita on 26/08/16.
//  Copyright © 2016 Nikita. All rights reserved.
//

import Foundation

public enum Size {
    case width
    case height
}

enum HandlerPriority: Int {
    case high
    case middle
    case low
}

public struct SafeArea {}
public var nui_safeArea: SafeArea {
    return SafeArea()
}

public final class Maker {
    
    typealias HandlerType = () -> Void

    unowned let view: UIView
    
    var handlers = ContiguousArray<(priority: HandlerPriority, handler: HandlerType)>()
    var newRect: CGRect

    private var widthParameter: ValueParameter?
    private var widthToParameter: SideParameter?
    
    private var heightParameter: ValueParameter?
    private var heightToParameter: SideParameter?
    
    private var leftParameter: SideParameter?
    private var topParameter: SideParameter?
    private var bottomParameter: SideParameter?
    private var rightParameter: SideParameter?
    
    init(view: UIView) {
        self.view = view
        self.newRect = view.frame
    }
    
    // MARK: Additions
    
    ///	Optional semantic property for improvements readability.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    public var and: Maker {
        return self
    }

    /// Creates edge relations.
    ///
    /// - parameter view:   The view, against which sets relations.
    /// - parameter insets: The insets for setting relations with `view`. Default value: `UIEdgeInsets.zero`.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func equal(to view: UIView, insets: UIEdgeInsets = .zero) -> Maker {
        let topView = RelationView<VerticalRelation>(view: view, relation: .top)
        let leftView = RelationView<HorizontalRelation>(view: view, relation: .left)
        let bottomView = RelationView<VerticalRelation>(view: view, relation: .bottom)
        let rightView = RelationView<HorizontalRelation>(view: view, relation: .right)
        
        return  top(to: topView, inset: insets.top)
                .left(to: leftView, inset: insets.left)
                .bottom(to: bottomView, inset: insets.bottom)
                .right(to: rightView, inset: insets.right)
    }
    
    /// Creates edge relations.
    ///
    /// It's useful method for configure some side relations in short form.
    ///
    /// ```
    /// Instead of writing:
    ///     maker.top(10).bottom(10).and.left(10)
    /// just write:
    ///     maker.edges(top:10, left:10, bottom:10) - it's more elegant.
    /// ```
    ///
    /// - parameter top:    The top inset relation relatively superview.
    /// - parameter left:   The left inset relation relatively superview.
    /// - parameter bottom: The bottom inset relation relatively superview.
    /// - parameter right:  The right inset relation relatively superview.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func edges(top: Number? = nil, left: Number? = nil, bottom: Number? = nil, right: Number? = nil) -> Maker {
        return apply(self.top, top).apply(self.left, left).apply(self.bottom, bottom).apply(self.right, right)
    }
    
    private func apply(_ f: ((Number) -> Maker), _ inset: Number?) -> Maker {
        return (inset != nil) ? f(inset!) : self
    }
    
    // MARK: High priority
    
    /// Installs constant width for current view.
    ///
    /// - parameter width: The width for view.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func width(_ width: Number) -> Maker {
        let handler = { [unowned self] in
            self.newRect.setValue(width.value, for: .width)
        }
        handlers.append((.high, handler))
        widthParameter = ValueParameter(value: width.value)
        return self
    }
    
    /// Creates width relation relatively another view = Aspect ration.
    ///
    /// Use this method when you want that your view's width equals to another view's height with some multiplier, for example.
    ///
    /// - note: You can not use this method with other relations except for `nui_width` and `nui_height`.
    ///
    /// - parameter relationView:   The view on which you set relation.
    /// - parameter multiplier:     The multiplier for views relation. Default multiplier value: 1.
    ///
    /// - returns: `Maker` instance for chaining relations.

    @discardableResult public func width(to relationView: RelationView<SizeRelation>, multiplier: Number = 1.0) -> Maker {
        let view = relationView.view
        let relationType = relationView.relationType
        
        let handler = { [unowned self] in
            if view != self.view {
                let width = self.relationSize(view: view, for: relationType) * multiplier.value
                self.newRect.setValue(width, for: .width)
            }
            else {
                if let parameter = self.heightParameter {
                    self.newRect.setValue(parameter.value * multiplier.value, for: .width)
                }
                else if let parameter = self.heightToParameter {
                    let width = self.relationSize(view: parameter.view, for: parameter.relationType) * (parameter.value * multiplier.value)
                    self.newRect.setValue(width, for: .width)
                }
                else {
                    guard let topParameter = self.topParameter, let bottomParameter = self.bottomParameter else {
                        return
                    }

                    let topViewY = self.convertedValue(for: topParameter.relationType, with: topParameter.view) + topParameter.value
                    let bottomViewY = self.convertedValue(for: bottomParameter.relationType, with: bottomParameter.view) - bottomParameter.value
                    
                    self.newRect.setValue((bottomViewY - topViewY) * multiplier.value, for: .width)
                }
            }
        }
        handlers.append((.high, handler))
        widthToParameter = SideParameter(view: view, value: multiplier.value, relationType: relationType)
        return self
        
    }
    
    /// Installs constant height for current view.
    ///
    /// - parameter height: The height for view.
    ///
    /// - returns: `Maker` instance for chaining relations.

    @discardableResult public func height(_ height: Number) -> Maker {
        let handler = { [unowned self] in
            self.newRect.setValue(height.value, for: .height)
        }
        handlers.append((.high, handler))
        heightParameter = ValueParameter(value: height.value)
        return self
    }
    
    /// Creates height relation relatively another view = Aspect ration.
    ///
    /// Use this method when you want that your view's height equals to another view's width with some multiplier, for example.
    ///
    /// - note: You can not use this method with other relations except for `nui_width` and `nui_height`.
    ///
    /// - parameter relationView:   The view on which you set relation.
    /// - parameter multiplier:     The multiplier for views relation. Default multiplier value: 1.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func height(to relationView: RelationView<SizeRelation>, multiplier: Number = 1.0) -> Maker {
        let view = relationView.view
        let relationType = relationView.relationType
        
        let handler = { [unowned self] in
            if view != self.view {
                let height = self.relationSize(view: view, for: relationType) * multiplier.value
                self.newRect.setValue(height, for: .height)
            }
            else {
                if let parameter = self.widthParameter {
                    self.newRect.setValue(parameter.value * multiplier.value, for: .height)
                }
                else if let parameter = self.widthToParameter {
                    let height = self.relationSize(view: parameter.view, for: parameter.relationType) * (parameter.value * multiplier.value)
                    self.newRect.setValue(height, for: .height)
                }
                else {
                    guard let leftParameter = self.leftParameter, let rightParameter = self.rightParameter else {
                        return
                    }

                    let leftViewX = self.convertedValue(for: leftParameter.relationType, with: leftParameter.view) + leftParameter.value
                    let rightViewX = self.convertedValue(for: rightParameter.relationType, with: rightParameter.view) - rightParameter.value
                    
                    self.newRect.setValue((rightViewX - leftViewX) * multiplier.value, for: .height)
                }
            }
        }
        handlers.append((.high, handler))
        heightToParameter = SideParameter(view: view, value: multiplier.value, relationType: relationType)
        return self
    }
    
    /// Installs constant width and height at the same time.
    ///
    /// - parameter width:  The width for view.
    /// - parameter height: The height for view.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func size(width: Number, height: Number) -> Maker {
        return self.width(width).height(height)
    }

    /// Creates left relation to superview.
    ///
    /// Use this method when you want to join left side of current view with left side of superview.
    ///
    /// - parameter inset: The inset for additional space between views. Default value: 0.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func left(inset: Number = 0.0) -> Maker {
        guard let superview = view.superview else {
            assertionFailure("Can not configure left relation to superview without superview.")
            return self
        }
        return left(to: RelationView(view: superview, relation: .left), inset: inset)
    }

    /// Creates a left relation to the superview's safe area.
    ///
    /// Use this method when you want to join a left side of current view with left edge of the superview's safe area.
    ///
    /// - note: In earlier versions of OS than iOS 11, it creates a left relation to a superview.
    ///
    /// - parameter safeArea:  The safe area of current view. Use a `nui_safeArea` - global property.
    /// - parameter inset:     The inset for additional space to safe area. Default value: 0.
    ///
    /// - returns: `Maker` instance for chaining relations.

    @discardableResult public func left(to safeArea: SafeArea, inset: Number = 0.0) -> Maker {
        if #available(iOS 11.0, *) {
            guard let superview = view.superview else {
                assertionFailure("Can not configure a left relation to the safe area without superview.")
                return self
            }
            return left(inset: superview.safeAreaInsets.left + inset.value)
        }
        else {
            return left(inset: inset)
        }
    }

    /// Creates left relation.
    ///
    /// Use this method when you want to join left side of current view with some horizontal side of another view.
    ///
    /// - note: You can not use this method with other relations except for `nui_left`, `nui_centerX` and `nui_right`.
    ///
    /// - parameter relationView:   The view on which you set left relation.
    /// - parameter inset:          The inset for additional space between views. Default value: 0.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func left(to relationView: RelationView<HorizontalRelation>, inset: Number = 0.0) -> Maker {
        let view = relationView.view
        let relationType = relationView.relationType

        let handler = { [unowned self] in
            let x = self.convertedValue(for: relationType, with: view) + inset.value
            self.newRect.setValue(x, for: .left)
        }
        handlers.append((.high, handler))
        leftParameter = SideParameter(view: view, value: inset.value, relationType: relationType)
        return self
    }
    
    /// Creates top relation to superview.
    ///
    /// Use this method when you want to join top side of current view with top side of superview.
    ///
    /// - parameter inset: The inset for additional space between views. Default value: 0.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func top(inset: Number = 0.0) -> Maker {
        guard let superview = view.superview else {
            assertionFailure("Can not configure a top relation to superview without superview.")
            return self
        }
        return top(to: RelationView(view: superview, relation: .top), inset: inset.value)
    }

    /// Creates a top relation to the superview's safe area.
    ///
    /// Use this method when you want to join a top side of current view with top edge of the superview's safe area.
    ///
    /// - note: In earlier versions of OS than iOS 11, it creates a top relation to a superview.
    ///
    /// - parameter safeArea:  The safe area of current view. Use a `nui_safeArea` - global property.
    /// - parameter inset:     The inset for additional space to safe area. Default value: 0.
    ///
    /// - returns: `Maker` instance for chaining relations.

    @discardableResult public func top(to safeArea: SafeArea, inset: Number = 0.0) -> Maker {
        if #available(iOS 11.0, *) {
            guard let superview = view.superview else {
                assertionFailure("Can not configure a top relation to the safe area without superview.")
                return self
            }
            return top(inset: superview.safeAreaInsets.top + inset.value)
        }
        else {
            return top(inset: inset)
        }
    }

    /// Creates top relation.
    ///
    /// Use this method when you want to join top side of current view with some vertical side of another view.
    ///
    /// - note: You can not use this method with other relations except for `nui_top`, `nui_centerY` and `nui_bottom`.
    ///
    /// - parameter relationView:  The view on which you set top relation.
    /// - parameter inset:         The inset for additional space between views. Default value: 0.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func top(to relationView: RelationView<VerticalRelation>, inset: Number = 0.0) -> Maker {
        let view = relationView.view
        let relationType = relationView.relationType
        
        let handler = { [unowned self] in
            let y = self.convertedValue(for: relationType, with: view) + inset.value
            self.newRect.setValue(y, for: .top)
        }
        handlers.append((.high, handler))
        topParameter = SideParameter(view: view, value: inset.value, relationType: relationType)
        return self
    }

    /// Creates сontainer relation.
    ///
    /// Use this method when you want to set `width` and `height` by wrapping all subviews.
    ///
    /// - note: First, you should configure all subviews and then call this method for `container view`.
    /// - note: Also important to understand, that it's not correct to call 'left' and 'right' relations together by subview, because
    ///         `container` sets width relatively width of subview and here is some ambiguous.
    ///
    /// - warning: Please make note that there is a more flexible container method:
    ///
    ///  ```
    ///  let container = [view1, view2].container(in: view) {}
    ///  ```
    ///
    /// - returns: `Maker` instance for chaining relations.

    @available(*, deprecated, message: "there is a more flexible container method - сheck the method description.")
    @discardableResult public func container() -> Maker {
        return _container()
    }
    
    @discardableResult func _container() -> Maker {
        var frame = CGRect.zero
        
        var minX: CGFloat = 0
        var minY: CGFloat = 0
        
        for subview in view.subviews {
            if subview.frame.origin.x < 0 {
                subview.frame.origin.x = 0
            }
            
            if subview.frame.origin.y < 0 {
                subview.frame.origin.y = 0
            }
            
            if subview.frame.origin.x < minX {
                minX = subview.frame.origin.x
            }
            if subview.frame.origin.y < minY {
                minY = subview.frame.origin.y
            }
        }
        
        for subview in view.subviews {
            subview.frame.origin.x -= minX
            subview.frame.origin.y -= minY
            
            frame = frame.union(subview.frame)
        }
        
        setHighPriorityValue(frame.width, for: .width)
        setHighPriorityValue(frame.height, for: .height)
        return self
    }

    /// Resizes the current view so it just encloses its subviews.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func sizeToFit() -> Maker {
        view.sizeToFit()
        setHighPriorityValue(view.bounds.width, for: .width)
        setHighPriorityValue(view.bounds.height, for: .height)
        return self
    }

    /// Calculates the size that best fits the specified size.
    ///
    /// ```
    ///     maker.sizeThatFits(size: CGSize(width: cell.frame.width, height: cell.frame.height)
    /// ```
    /// - parameter size: The size for best-fitting.
    ///
    /// - returns: `Maker` instance for chaining relations.

    @discardableResult public func sizeThatFits(size: CGSize) -> Maker {
        let fitSize = view.sizeThatFits(size)
        let width = min(size.width, fitSize.width)
        let height = min(size.height, fitSize.height)
        setHighPriorityValue(width, for: .width)
        setHighPriorityValue(height, for: .height)
        return self
    }

    /// Resizes and moves the receiver view so it just encloses its subviews only for height.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func heightToFit() -> Maker {
        return heightThatFits(maxHeight: CGFloat.greatestFiniteMagnitude)
    }

    /// Calculates the height that best fits the specified size.
    ///
    /// - returns: `Maker` instance for chaining relations.

    @discardableResult public func heightThatFits(maxHeight: Number) -> Maker {
        let handler = { [unowned self] in
            let fitWidth: CGFloat

            if let parameter = self.widthParameter {
                fitWidth = parameter.value
            }
            else if let parameter = self.widthToParameter {
                fitWidth = self.relationSize(view: parameter.view, for: parameter.relationType) * parameter.value
            }
            else if let leftParameter = self.leftParameter, let rightParameter = self.rightParameter {
                let leftViewX = self.convertedValue(for: leftParameter.relationType, with: leftParameter.view) + leftParameter.value
                let rightViewX = self.convertedValue(for: rightParameter.relationType, with: rightParameter.view) - rightParameter.value

                fitWidth = rightViewX - leftViewX
            }
            else {
                fitWidth = .greatestFiniteMagnitude
            }

            let fitSize = self.view.sizeThatFits(CGSize(width: fitWidth, height: .greatestFiniteMagnitude))
            self.newRect.setValue(min(maxHeight.value, fitSize.height), for: .height)
        }
        handlers.append((.high, handler))
        return self
    }

    /// Resizes and moves the receiver view so it just encloses its subviews only for width.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func widthToFit() -> Maker {
        return widthThatFits(maxWidth: CGFloat.greatestFiniteMagnitude)
    }

    /// Calculates the width that best fits the specified size.
    ///
    /// - returns: `Maker` instance for chaining relations.

    @discardableResult public func widthThatFits(maxWidth: Number) -> Maker {
        let handler = { [unowned self] in
            let fitHeight: CGFloat

            if let parameter = self.heightParameter {
                fitHeight = parameter.value
            }
            else if let parameter = self.heightToParameter {
                fitHeight = self.relationSize(view: parameter.view, for: parameter.relationType) * parameter.value
            }
            else if let topParameter = self.topParameter, let bottomParameter = self.bottomParameter {
                let topViewY = self.convertedValue(for: topParameter.relationType, with: topParameter.view) + topParameter.value
                let bottomViewY = self.convertedValue(for: bottomParameter.relationType, with: bottomParameter.view) - bottomParameter.value

                fitHeight = bottomViewY - topViewY
            }
            else {
                fitHeight = .greatestFiniteMagnitude
            }

            let fitSize = self.view.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: fitHeight))
            self.newRect.setValue(min(maxWidth.value, fitSize.width), for: .width)
        }

        handlers.append((.high, handler))
        return self
    }

    // MARK: Middle priority
    
    /// Creates margin relation for superview.
    ///
    /// - parameter inset: The inset for setting top, left, bottom and right relations for superview.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func margin(_ inset: Number) -> Maker {
        let inset = inset.value
        return edges(insets: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset))
    }
    
    /// Creates edge relations for superview.
    ///
    /// - parameter insets: The insets for setting relations for superview.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func edges(insets: UIEdgeInsets) -> Maker {
        guard let superview = view.superview else {
            assertionFailure("Can not create edge relations without superview.")
            return self
        }
        
        let handler = { [unowned self, unowned superview] in
            let width = superview.bounds.width - (insets.left + insets.right)
            let height = superview.bounds.height - (insets.top + insets.bottom)
            let frame = CGRect(x: insets.left, y: insets.top, width: width, height: height)
            self.newRect = frame
        }
        handlers.append((.middle, handler))
        return self
    }
    
    /// Creates bottom relation to superview.
    ///
    /// Use this method when you want to join bottom side of current view with bottom side of superview.
    ///
    /// - parameter inset: The inset for additional space between views. Default value: 0.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func bottom(inset: Number = 0.0) -> Maker {
        guard let superview = view.superview else {
            assertionFailure("Can not configure a bottom relation to superview without superview.")
            return self
        }
        return bottom(to: RelationView(view: superview, relation: .bottom), inset: inset)
    }

    /// Creates a bottom relation to the superview's safe area.
    ///
    /// Use this method when you want to join a bottom side of current view with bottom edge of the superview's safe area.
    ///
    /// - note: In earlier versions of OS than iOS 11, it creates a bottom relation to a superview.
    ///
    /// - parameter safeArea:  The safe area of current view. Use a `nui_safeArea` - global property.
    /// - parameter inset:     The inset for additional space to safe area. Default value: 0.
    ///
    /// - returns: `Maker` instance for chaining relations.

    @discardableResult public func bottom(to safeArea: SafeArea, inset: Number = 0.0) -> Maker {
        if #available(iOS 11.0, *) {
            guard let superview = view.superview else {
                assertionFailure("Can not configure a bottom relation to the safe area without superview.")
                return self
            }
            return bottom(inset: superview.safeAreaInsets.bottom + inset.value)
        }
        else {
            return bottom(inset: inset)
        }
    }
    
    /// Creates bottom relation.
    ///
    /// Use this method when you want to join bottom side of current view with some vertical side of another view.
    ///
    /// - note: You can not use this method with other relations except for `nui_top`, `nui_centerY` and `nui_bottom`.
    ///
    /// - parameter relationView:   The view on which you set bottom relation.
    /// - parameter inset:          The inset for additional space between views. Default value: 0.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func bottom(to relationView: RelationView<VerticalRelation>, inset: Number = 0.0) -> Maker {
        let view = relationView.view
        let relationType = relationView.relationType
        
        let handler = { [unowned self] in
            if self.topParameter != nil {
                let height = fabs(self.newRect.minY - self.convertedValue(for: relationType, with: view)) - inset.value
                self.newRect.setValue(height, for: .height)
            }
            else {
                let y = self.convertedValue(for: relationType, with: view) - inset.value - self.newRect.height
                self.newRect.setValue(y, for: .top)
            }
        }
        handlers.append((.middle, handler))
        bottomParameter = SideParameter(view: view, value: inset.value, relationType: relationType)
        return self
    }
    
    /// Creates right relation to superview.
    ///
    /// Use this method when you want to join right side of current view with right side of superview.
    ///
    /// - parameter inset: The inset for additional space between views. Default value: 0.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func right(inset: Number = 0.0) -> Maker {
        guard let superview = view.superview else {
            assertionFailure("Can not configure a right relation to superview without superview.")
            return self
        }
        return right(to: RelationView(view: superview, relation: .right), inset: inset.value)
    }

    /// Creates a right relation to the superview's safe area.
    ///
    /// Use this method when you want to join a right side of current view with right edge of the superview's safe area.
    ///
    /// - note: In earlier versions of OS than iOS 11, it creates a right relation to a superview.
    ///
    /// - parameter safeArea:  The safe area of current view. Use a `nui_safeArea` - global property.
    /// - parameter inset:     The inset for additional space to safe area. Default value: 0.
    ///
    /// - returns: `Maker` instance for chaining relations.

    @discardableResult public func right(to safeArea: SafeArea, inset: Number = 0.0) -> Maker {
        if #available(iOS 11.0, *) {
            guard let superview = view.superview else {
                assertionFailure("Can not configure a right relation to the safe area without superview.")
                return self
            }
            return right(inset: superview.safeAreaInsets.right + inset.value)
        }
        else {
            return right(inset: inset)
        }
    }

    /// Creates right relation.
    ///
    /// Use this method when you want to join right side of current view with some horizontal side of another view.
    ///
    /// - note: You can not use this method with other relations except for `nui_left`, `nui_centerX` and `nui_right`.
    ///
    /// - parameter relationView:     The view on which you set right relation.
    /// - parameter inset:            The inset for additional space between views. Default value: 0.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func right(to relationView: RelationView<HorizontalRelation>, inset: Number = 0.0) -> Maker {
        let view = relationView.view
        let relationType = relationView.relationType
        
        let handler = { [unowned self] in
            if self.leftParameter != nil {
                let width = fabs(self.newRect.minX - self.convertedValue(for: relationType, with: view)) - inset.value
                self.newRect.setValue(width, for: .width)
            }
            else {
                let x = self.convertedValue(for: relationType, with: view) - inset.value - self.newRect.width
                self.newRect.setValue(x, for: .left)
            }
        }
        handlers.append((.middle, handler))
        rightParameter = SideParameter(view: view, value: inset.value, relationType: relationType)
        return self
    }
    
    // MARK: Low priority

    /// Set up the corner radius value.
    ///
    /// - returns: `Maker` instance for chaining relations.

    @discardableResult public func cornerRadius(_ cornerRadius: Number) -> Maker {
        let handler = { [unowned self] in
            self.view.layer.cornerRadius = cornerRadius.value
        }
        handlers.append((.low, handler))
        return self
    }

    /// Set up the corner radius value as either a half-width or half-height.
    ///
    /// - returns: `Maker` instance for chaining relations.

    @discardableResult public func cornerRadius(byHalf type: Size) -> Maker {
        let handler = { [unowned self] in
            if case Size.width = type {
                self.view.layer.cornerRadius = self.newRect.width / 2
            }
            else {
                self.view.layer.cornerRadius = self.newRect.height / 2
            }
        }
        handlers.append((.low, handler))
        return self
    }

    /// Creates center relation to superview.
    ///
    /// Use this method when you want to center view by both axis relativity superview.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func center() -> Maker {
        guard let superview = view.superview else {
            assertionFailure("Can not configure a center relation to superview without superview.")
            return self
        }
        return center(to: superview)
    }
    
    /// Creates center relation.
    ///
    /// Use this method when you want to center view by both axis relativity another view.
    ///
    /// - parameter view: The view on which you set center relation.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func center(to view: UIView) -> Maker {
        return centerX(to: RelationView<HorizontalRelation>(view: view, relation: .centerX))
                .centerY(to: RelationView<VerticalRelation>(view: view, relation: .centerY))
    }
    
    /// Creates centerY relation.
    ///
    /// Use this method when you want to join centerY of current view with centerY of superview.
    ///
    /// - parameter offset: Additional offset for centerY point. Default value: 0.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func centerY(offset: Number = 0.0) -> Maker {
        guard let superview = view.superview else {
            assertionFailure("Can not configure a centerY relation to superview without superview.")
            return self
        }
        return centerY(to: RelationView(view: superview, relation: .centerY), offset: offset.value)
    }
    
    /// Creates centerY relation.
    ///
    /// Use this method when you want to join centerY of current view with some vertical side of another view.
    ///
    /// - note: You can not use this method with other relations except for `nui_top`, `nui_centerY` and `nui_bottom`.
    ///
    /// - parameter relationView:   The view on which you set centerY relation.
    /// - parameter offset:         Additional offset for centerY point. Default value: 0.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func centerY(to relationView: RelationView<VerticalRelation>, offset: Number = 0.0) -> Maker {
        let view = relationView.view
        let relationType = relationView.relationType
        
        let handler = { [unowned self] in
            let y = self.convertedValue(for: relationType, with: view) - self.newRect.height/2 - offset.value
            self.newRect.setValue(y, for: .top)
        }
        handlers.append((.low, handler))
        return self
    }
    
    /// Creates centerY relation between two views.
    ///
    /// Use this method when you want to configure centerY point between two following views.
    ///
    /// - parameter view1: The first view between which you set `centerY` relation.
    /// - parameter view2: The second view between which you set `centerY` relation.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func centerY(between view1: UIView, _ view2: UIView) -> Maker {
        let topView = view1.frame.maxY > view2.frame.minY ? view2 : view1
        let bottomView = topView === view1 ? view2 : view1
        return self.centerY(between: topView.nui_bottom, bottomView.nui_top)
    }

    /// Creates centerY relation between two relation views.
    ///
    /// Use this method when you want to configure centerY point between two relations views.
    ///
    /// - parameter relationView1: The first relation view between which you set `centerY` relation.
    /// - parameter relationView2: The second relation view between which you set `centerY` relation.
    ///
    /// - returns: `Maker` instance for chaining relations.

    @discardableResult public func centerY(between relationView1: RelationView<VerticalRelation>,
                                           _ relationView2: RelationView<VerticalRelation>) -> Maker {
        let view1 = relationView1.view
        let view2 = relationView2.view

        let relationType1 = relationView1.relationType
        let relationType2 = relationView2.relationType

        let handler = { [unowned self] in
            let y1 = self.convertedValue(for: relationType1, with: view1)
            let y2 = self.convertedValue(for: relationType2, with: view2)

            let topY = y1 < y2 ? y1 : y2
            let bottomY = y1 >= y2 ? y1 : y2

            let y = bottomY - (bottomY - topY)/2 - self.newRect.height/2
            self.newRect.setValue(y, for: .top)
        }
        handlers.append((.low, handler))
        return self
    }

    /// Creates centerX relation to superview.
    ///
    /// Use this method when you want to join centerX of current view with centerX of superview.
    ///
    /// - parameter offset: Additional offset for centerX point. Default value: 0.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func centerX(offset: Number = 0.0) -> Maker {
        guard let superview = view.superview else {
            assertionFailure("Can not configure a centerX relation to superview without superview.")
            return self
        }
        return centerX(to: RelationView(view: superview, relation: .centerX), offset: offset.value)
    }
    
    /// Creates centerX relation.
    ///
    /// Use this method when you want to join centerX of current view with some horizontal side of another view.
    ///
    /// - note: You can not use this method with other relations except for `nui_left`, `nui_centerX` and `nui_right`.
    ///
    /// - parameter relationView:   The view on which you set centerX relation.
    /// - parameter offset:         Additional offset for centerX point. Default value: 0.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func centerX(to relationView: RelationView<HorizontalRelation>, offset: Number = 0.0) -> Maker {
        let view = relationView.view
        let relationType = relationView.relationType
        
        let handler = { [unowned self] in
            let x = self.convertedValue(for: relationType, with: view) - self.newRect.width/2 - offset.value
            self.newRect.setValue(x, for: .left)
        }
        handlers.append((.low, handler))
        return self
    }
    
    /// Creates centerX relation between two views.
    ///
    /// Use this method when you want to configure centerX point between two following views.
    ///
    /// - parameter view1: The first view between which you set `centerX` relation.
    /// - parameter view2: The second view between which you set `centerX` relation.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func centerX(between view1: UIView, _ view2: UIView) -> Maker {
        let leftView = view1.frame.maxX > view2.frame.minX ? view2 : view1
        let rightView = leftView === view1 ? view2 : view1
        return self.centerX(between: leftView.nui_right, rightView.nui_left)
    }

    /// Creates centerX relation between two relation views.
    ///
    /// Use this method when you want to configure centerX point between two relations views.
    ///
    /// - parameter relationView1: The first relation view between which you set `centerX` relation.
    /// - parameter relationView2: The second relation view between which you set `centerX` relation.
    ///
    /// - returns: `Maker` instance for chaining relations.

    @discardableResult public func centerX(between relationView1: RelationView<HorizontalRelation>,
                                           _ relationView2: RelationView<HorizontalRelation>) -> Maker {
        let view1 = relationView1.view
        let view2 = relationView2.view

        let relationType1 = relationView1.relationType
        let relationType2 = relationView2.relationType

        let handler = { [unowned self] in
            let x1 = self.convertedValue(for: relationType1, with: view1)
            let x2 = self.convertedValue(for: relationType2, with: view2)

            let rightX = x1 < x2 ? x1 : x2
            let leftX = x1 >= x2 ? x1 : x2

            let x = rightX - (rightX - leftX)/2 - self.newRect.width/2
            self.newRect.setValue(x, for: .left)
        }
        handlers.append((.low, handler))
        return self
    }

    /// Just setting centerX.
    ///
    /// - parameter value: The value for setting centerX.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func setCenterX(value: Number) -> Maker {
        let handler = { [unowned self] in
            self.newRect.setValue(value.value, for: .centerX)
        }
        handlers.append((.low, handler))
        return self
    }
    
    /// Just setting centerY.
    ///
    /// - parameter value: The value for setting centerY.
    ///
    /// - returns: `Maker` instance for chaining relations.
    
    @discardableResult public func setCenterY(value: Number) -> Maker {
        let handler = { [unowned self] in
            self.newRect.setValue(value.value, for: .centerY)
        }
        handlers.append((.low, handler))
        return self
    }
    
    // MARK: Private

    private func setHighPriorityValue(_ value: CGFloat, for relationType: RelationType) {
        let handler = { [unowned self] in
            self.newRect.setValue(value, for: relationType)
        }
        handlers.append((.high, handler))
        
        switch relationType {
        case .width:  widthParameter = ValueParameter(value: value)
        case .height: heightParameter = ValueParameter(value: value)
        default: break
        }
    }
}

//
//  UIView+Installer.swift
//  Framezilla
//
//  Created by Nikita on 27/08/16.
//  Copyright © 2016 Nikita. All rights reserved.
//

import Foundation
import ObjectiveC

public let DEFAULT_STATE = "DEFAULT STATE"

private var stateTypeAssociationKey: UInt8 = 0
private var nxStateTypeAssociationKey: UInt8 = 1

public extension UIView {
    
    /// Apply new configuration state without frame updating.
    ///
    /// - note: Use `DEFAULT_STATE` for setting the state to the default value.
    
    @available(*, message: "Renamed due to conflict with Objective-C library - Framer", unavailable, renamed: "nx_state")
    public var nui_state: AnyHashable {
        get {
            if let value = objc_getAssociatedObject(self, &stateTypeAssociationKey) as? AnyHashable {
                return value
            }
            else {
                return DEFAULT_STATE
            }
        }
        set {
            objc_setAssociatedObject(self, &stateTypeAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Apply new configuration state without frame updating.
    ///
    /// - note: Use `DEFAULT_STATE` for setting the state to the default value.
    
    public var nx_state: AnyHashable {
        get {
            if let value = objc_getAssociatedObject(self, &nxStateTypeAssociationKey) as? AnyHashable {
                return value
            }
            else {
                return DEFAULT_STATE
            }
        }
        set {
            objc_setAssociatedObject(self, &nxStateTypeAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

public extension UIView {
    
    @available(*, deprecated, renamed: "configureFrame(state:installerBlock:)")
    public func configureFrames(state: AnyHashable = DEFAULT_STATE, installerBlock: InstallerBlock) {
        Maker.configure(view: self, for: state, installerBlock: installerBlock)
    }
    
    /// Configures frame of current view for special state.
    ///
    /// - note: When you configure frame without implicit state parameter (default value), frame configures for the `DEFAULT_STATE`.
    ///
    /// - parameter state:          The state for which you configure frame. Default value: `DEFAULT_STATE`.
    /// - parameter installerBlock: The installer block within which you can configure frame relations.
    
    public func configureFrame(state: AnyHashable = DEFAULT_STATE, installerBlock: InstallerBlock) {
        Maker.configure(view: self, for: state, installerBlock: installerBlock)
    }
    
    /// Configures frame of current view for special states.
    ///
    /// - note: Don't forget about `DEFAULT_VALUE`.
    ///
    /// - parameter states:         The states for which you configure frame.
    /// - parameter installerBlock: The installer block within which you can configure frame relations.
    
    public func configureFrame(states: [AnyHashable], installerBlock: InstallerBlock) {
        for state in states {
            Maker.configure(view: self, for: state, installerBlock: installerBlock)
        }
    }
}

public extension Sequence where Iterator.Element: UIView {
    
    /// Configures frames of the views for special state.
    ///
    /// - note: When you configure frame without implicit state parameter (default value), frame configures for the `DEFAULT_STATE`.
    ///
    /// - parameter state:          The state for which you configure frame. Default value: `DEFAULT_STATE`.
    /// - parameter installerBlock: The installer block within which you can configure frame relations.
    
    public func configureFrames(state: AnyHashable = DEFAULT_STATE, installerBlock: InstallerBlock) {
        for view in self {
            view.configureFrame(state: state, installerBlock: installerBlock)
        }
    }
    
    /// Configures frames of the views for special states.
    ///
    /// - note: Don't forget about `DEFAULT_VALUE`.
    ///
    /// - parameter states:         The states for which you configure frames.
    /// - parameter installerBlock: The installer block within which you can configure frame relations.
    
    public func configureFrames(states: [AnyHashable], installerBlock: InstallerBlock) {
        for view in self {
            view.configureFrame(states: states, installerBlock: installerBlock)
        }
    }
}

public enum ContainerRelation {
    case width(Number)
    case height(Number)
    case horizontal(left: Number, right: Number)
    case vertical(top: Number, bottom: Number)
}

public extension Collection where Iterator.Element: UIView {

    /// Configures all subview within a passed container.
    ///
    /// Use this method when you want to calculate width and height by wrapping all subviews. Or use static parameters.
    ///
    /// - note: It automatically adds all subviews to the container. Don't add subviews manually.
    /// - note: If you don't use a static width for instance, important to understand, that it's not correct to call 'left' and 'right' relations together by subviews,
    ///         because `container` sets width relatively width of subviews and here is some ambiguous.
    ///
    /// - parameter view:                The view where a container will be added.
    /// - parameter relation:            The relation of `ContainerRelation` type.
    ///     - `width`:                   The width of a container. If you specify a width only a dynamic height will be calculated.
    ///     - `height`:                  The height of a container. If you specify a height only a dynamic width will be calculated.
    ///     - `horizontal(left, right)`: The left and right insets of a container. If you specify these parameters only a dynamic height will be calculated.
    ///     - `vertical(top, bottom)`:   The top and bototm insets of a container. If you specify these parameters only a dynamic width will be calculated.
    /// - parameter installerBlock:      The installer block within which you should configure frames for all subviews.

    public func configure(container: UIView, relation: ContainerRelation? = nil, installerBlock: () -> Void) {
        container.frame = .zero

        var relationWidth: CGFloat?
        var relationHeight: CGFloat?
        
        if let relation = relation {
            switch relation {
            case let .width(width):
                container.frame.size.width = width.value
                relationWidth = width.value
                
            case let .height(height):
                container.frame.size.height = height.value
                relationHeight = height.value
                
            case let .horizontal(lInset, rInset):
                container.configureFrame { maker in
                    maker.left(inset: lInset).right(inset: rInset)
                }
                let width = container.frame.width
                container.frame = .zero
                container.frame.size.width = width
                relationWidth = width
                
            case let .vertical(tInset, bInset):
                container.configureFrame { maker in
                    maker.top(inset: tInset).bottom(inset: bInset)
                }
                let height = container.frame.height
                container.frame = .zero
                container.frame.size.height = height
                relationHeight = height
            }
        }

        for subview in self where subview.superview != container {
            container.addSubview(subview)
        }

        installerBlock()
        container.configureFrame { maker in
            maker._container()
        }
        
        if let width = relationWidth {
            container.frame.size.width = width
        }
        
        if let height = relationHeight {
            container.frame.size.height = height
        }
        
        installerBlock()
    }

    /// Creates a сontainer view and configures all subview within this container.
    ///
    /// Use this method when you want to calculate `width` and `height` by wrapping all subviews. Or use static parameters.
    ///
    /// - note: It automatically adds all subviews to the container. Don't add subviews manually. A generated container is automatically added to a `view` as well.
    /// - note: If you don't use a static width for instance, important to understand, that it's not correct to call 'left' and 'right' relations together by subviews,
    ///         because `container` sets width relatively width of subviews and here is some ambiguous.
    ///
    /// - parameter view:                The view where a container will be added.
    /// - parameter relation:            The relation of `ContainerRelation` type.
    ///     - `width`:                   The width of a container. If you specify a width only a dynamic height will be calculated.
    ///     - `height`:                  The height of a container. If you specify a height only a dynamic width will be calculated.
    ///     - `horizontal(left, right)`: The left and right insets of a container. If you specify these parameters only a dynamic height will be calculated.
    ///     - `vertical(top, bottom)`:   The top and bototm insets of a container. If you specify these parameters only a dynamic width will be calculated.
    /// - parameter installerBlock:      The installer block within which you should configure frames for all subviews.
    ///
    /// - returns: Container view.

    public func container(in view: UIView, relation: ContainerRelation? = nil, installerBlock: () -> Void) -> UIView {
        let container: UIView
        if let superView = self.first?.superview {
            container = superView
        }
        else {
            container = UIView()
        }

        view.addSubview(container)
        configure(container: container, relation: relation, installerBlock: installerBlock)
        return container
    }
}

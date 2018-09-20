//
//  Array+Stack.swift
//  Framezilla
//
//  Created by Nikita Ermolenko on 19/02/2017.
//
//

public enum StackAxis: Int {
    case horizontal
    case vertical
}

public extension Collection where Iterator.Element: UIView, Self.Index == Int, Self.IndexDistance == Int {
    
    /// Arranges views in the order of list along a vertical or horizontal axis, with spacing property.
    ///
    /// - note: You have to change the `nx_state` of the container, not the arranged subviews.
    ///
    /// - parameter axis:      A stack with a horizontal axis is a row of arranged subviews, and a stack with a vertical axis is a column of arranged subviews.
    /// - parameter spacing:   Spacing between arranged subviews.
    /// - parameter state:     The state for which you configure frame.
    
    public func stack(axis: StackAxis, spacing: Number = 0.0, state: AnyHashable = DEFAULT_STATE) {
        for view in self {
            guard view.superview != nil else {
                assertionFailure("Can not configure stack relation without superview.")
                return
            }
        }

        let superview = self[0].superview!
        for view in self where view.superview != superview {
            assertionFailure("All views should have the same superview.")
        }
        
        guard superview.nx_state == state else {
            return
        }
        
        let count = CGFloat(self.count)
        var prevView = self[0]
        
        switch axis {
        case .horizontal:
            let width = (superview.bounds.width - (count - 1) * spacing.value) / count
            let height = superview.bounds.height

            for (index, view) in self.enumerated() {
                view.configureFrame { maker in
                    maker.size(width: width, height: height)
                    if index == 0 {
                        maker.left()
                    }
                    else {
                        maker.left(to: prevView.nui_right, inset: spacing)
                    }
                }
                prevView = view
            }
        case .vertical:
            let width = superview.bounds.width
            let height = (superview.bounds.height - (count - 1) * spacing.value) / count

            for (index, view) in self.enumerated() {
                view.configureFrame { maker in
                    maker.size(width: width, height: height)
                    if index == 0 {
                        maker.top()
                    }
                    else {
                        maker.top(to: prevView.nui_bottom, inset: spacing)
                    }
                }
                prevView = view
            }
            
        }
    }
}

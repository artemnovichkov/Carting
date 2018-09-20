//
//  UIView+Relations.swift
//  Framezilla
//
//  Created by Nikita on 26/08/16.
//  Copyright © 2016 Nikita. All rights reserved.
//

/// Phantom type for `nui_left`, `nui_right`, `nui_centerX` relations.

public protocol HorizontalRelation {}

/// Phantom type for `nui_top`, `nui_bottom`, `nui_centerY` relations.

public protocol VerticalRelation {}

/// Phantom type for `nui_height`, `nui_widht` relations.

public protocol SizeRelation {}

public final class RelationView<Relation> {

    unowned var view: UIView
    var relationType: RelationType
    
    init(view: UIView, relation: RelationType) {
        self.view = view
        self.relationType = relation
    }
}

enum RelationType {
    case bottom
    case top
    case left
    case right
    case width
    case widthTo
    case height
    case heightTo
    case centerX
    case centerY
}

public extension UIView {
    
    /// Width relation of current view.
    
    public var nui_width: RelationView<SizeRelation> {
        return RelationView(view: self, relation: .width)
    }
    
    /// Height relation of current view.
    
    public var nui_height: RelationView<SizeRelation> {
        return RelationView<SizeRelation>(view: self, relation: .height)
    }
    
    /// Left relation of current view.

    public var nui_left: RelationView<HorizontalRelation> {
        return RelationView<HorizontalRelation>(view: self, relation: .left)
    }
    
    /// Right relation of current view.
    
    public var nui_right: RelationView<HorizontalRelation> {
        return RelationView<HorizontalRelation>(view: self, relation: .right)
    }
    
    /// Top relation of current view.
    
    public var nui_top: RelationView<VerticalRelation> {
        return RelationView<VerticalRelation>(view: self, relation: .top)
    }
    
    /// Bottom relation of current view.
    
    public var nui_bottom: RelationView<VerticalRelation> {
        return RelationView<VerticalRelation>(view: self, relation: .bottom)
    }
    
    /// CenterX relation of current view.
    
    public var nui_centerX: RelationView<HorizontalRelation> {
        return RelationView<HorizontalRelation>(view: self, relation: .centerX)
    }
    
    /// CenterY relation of current view.
    
    public var nui_centerY: RelationView<VerticalRelation> {
        return RelationView<VerticalRelation>(view: self, relation: .centerY)
    }
}

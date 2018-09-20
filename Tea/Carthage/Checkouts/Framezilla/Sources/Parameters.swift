//
//  Parameters.swift
//  Framezilla
//
//  Created by Nikita Ermolenko on 30/06/2017.
//
//

import Foundation

final class ValueParameter {
    let value: CGFloat

    init(value: CGFloat) {
        self.value = value
    }
}

final class SideParameter {
    
    unowned let view: UIView
    let value: CGFloat
    let relationType: RelationType
    
    init(view: UIView, value: CGFloat, relationType: RelationType) {
        self.view = view
        self.value = value
        self.relationType = relationType
    }
}

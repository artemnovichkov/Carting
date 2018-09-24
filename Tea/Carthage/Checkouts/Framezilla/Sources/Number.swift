//
//  Number.swift
//  Framezilla
//
//  Created by Nikita Ermolenko on 19/02/2017.
//
//

import Foundation

public protocol Number {
    var value: CGFloat { get }
}

extension CGFloat: Number {
    public var value: CGFloat {
        return self
    }
}

extension Double: Number {
    public var value: CGFloat {
        return CGFloat(self)
    }
}

extension Int: Number {
    public var value: CGFloat {
        return CGFloat(self)
    }
}

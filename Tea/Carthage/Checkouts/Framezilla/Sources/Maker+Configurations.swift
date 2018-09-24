//
//  Maker+Configurations.swift
//  Framezilla
//
//  Created by Nikita on 27/08/16.
//  Copyright © 2016 Nikita. All rights reserved.
//

import Foundation

postfix operator <<
postfix operator >>

/// Start frame configuration for `DEFAULT_STATE` state.
///
/// - note: Don't forget to call `>>` operator for ending of configuration.
///
/// - parameter view: The view you are configuring.
///
/// - returns: `Maker` instance for chaining relations.

public postfix func << (view: UIView) -> Maker {
    let maker = Maker(view: view)
    maker.newRect = view.frame
    return maker
}

/// End frame configuration.

public postfix func >> (maker: Maker) {
    if (maker.view.nx_state as? String) == DEFAULT_STATE {
        maker.configureFrame()
    }
}

public typealias InstallerBlock = (Maker) -> Void

extension Maker {
    
    class func configure(view: UIView, for state: AnyHashable, installerBlock: InstallerBlock) {
        if view.nx_state == state {
            let maker = Maker(view: view)
            
            maker.newRect = view.frame
            installerBlock(maker)
            
            maker.configureFrame()
        }
    }
    
    fileprivate func configureFrame() {
        handlers.sorted {
            $0.priority.rawValue <= $1.priority.rawValue
        }.forEach {
            $0.handler()
        }

        view.frame = newRect
    }
}

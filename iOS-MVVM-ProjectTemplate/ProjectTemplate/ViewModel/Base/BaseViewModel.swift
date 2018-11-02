//
//  BaseViewModel.swift
//  ProjectTemplate
//
//  Created by Jan Misar on 16.08.18.
//

import Foundation

/// Base class for all view models contained in app.
class BaseViewModel {

    static var logEnabled: Bool = true

    init() {
        if BaseViewModel.logEnabled {
            NSLog("🧠 👶 \(self)")
        }
    }

    deinit {
        if BaseViewModel.logEnabled {
            NSLog("🧠 ⚰️ \(self)")
        }
    }
}

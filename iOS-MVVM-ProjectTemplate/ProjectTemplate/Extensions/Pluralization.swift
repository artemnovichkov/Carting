//
//  Pluralization.swift
//  ProjectTemplate
//
//  Created by Jakub Olejník on 05/02/2018.
//

import Smartling_i18n

private class BundleLocator { }

extension L10n {
    static func pluralized(base: String, count: Int, table: String? = nil) -> String {
        let format = Bundle(for: BundleLocator.self).pluralizedString(withKey: base, defaultValue: base, table: table, pluralValue: Float(count), forLocalization: "cs")
        return format.map { String(format: $0, count) } ?? ""
    }
}

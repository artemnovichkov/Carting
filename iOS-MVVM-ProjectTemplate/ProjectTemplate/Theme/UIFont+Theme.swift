import UIKit

extension UIFont: ThemeProvider { }

// Load fonts when first used from bundle root directory
private final class BundleLocator {}
private let fonts: [URL] = {
    // swiftlint:disable:next force_unwrapping
    let bundleURL = Bundle(for: BundleLocator.self).resourceURL!
    let resourceURLs = try? FileManager.default.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
    let fonts = resourceURLs?.filter { $0.pathExtension == "otf" || $0.pathExtension == "ttf" } ?? []

    fonts.forEach { CTFontManagerRegisterFontsForURL($0 as CFURL, CTFontManagerScope.process, nil) }

    return fonts
}()

extension Theme where Base: UIFont {
    static func regular(_ size: CGFloat) -> UIFont {
        _ = fonts
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }

    static func bold(_ size: CGFloat) -> UIFont {
        _ = fonts
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }
}

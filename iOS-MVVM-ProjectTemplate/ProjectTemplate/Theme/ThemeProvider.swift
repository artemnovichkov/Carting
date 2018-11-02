import Foundation

struct Theme<Base> { }

protocol ThemeProvider { }

extension ThemeProvider {
    static var theme: Theme<Self>.Type { return Theme<Self>.self }

    var theme: Theme<Self> { return Theme<Self>() } // theoretically unneccessary allocation overhead every call, but SnapKit uses the same pattern so...
}

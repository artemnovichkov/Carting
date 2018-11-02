import UIKit

extension UIColor: ThemeProvider { }

extension Theme where Base: UIColor { // all app colors should be available in UIColor.theme namespace
    static var ackeeBlue: UIColor { return .blue }
}

//
// Xcore
// Copyright © 2014 Xcore
// MIT license, see LICENSE file for details
//

import UIKit
import SafariServices
import ObjectiveC

/// Attempts to open the resource at the specified URL.
///
/// - Parameters:
///   - url:  The url to open.
///   - from: A view controller that wants to open the url.
func open(url: URL, from viewController: UIViewController) {
    let vc = SFSafariViewController(url: url)
    viewController.present(vc, animated: true)
}

extension UIDatePicker {
    @nonobjc
    open var textColor: UIColor? {
        get { value(forKey: "textColor") as? UIColor }
        set { setValue(newValue, forKey: "textColor") }
    }
}

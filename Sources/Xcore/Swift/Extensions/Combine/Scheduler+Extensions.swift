//
// Xcore
// Copyright © 2020 Xcore
// MIT license, see LICENSE file for details
//

import Foundation
import Combine

extension Scheduler where Self == DispatchQueue {
    public static var main: Self {
        DispatchQueue.main
    }
}

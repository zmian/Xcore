//
// Xcore
// Copyright © 2019 Xcore
// MIT license, see LICENSE file for details
//

import AVFoundation

extension CharacterSet {
    /// English letters (upper and lowercase) and space.
    public static let lettersAndSpaces = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
    )

    /// A character set containing the subset of characters from the category of
    /// Decimal Numbers.
    ///
    /// Informally, this set represent only the decimal values 0 through 9.
    public static let numbers = CharacterSet(charactersIn: "0123456789")
}

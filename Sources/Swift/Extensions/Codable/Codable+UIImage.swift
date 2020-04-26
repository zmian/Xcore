//
// Xcore
// Copyright © 2020 Xcore
// MIT license, see LICENSE file for details
//

import Foundation

public enum EncodingImageType {
    case png
    case jpeg(quality: CGFloat)
}

extension KeyedEncodingContainer {
    public mutating func encode(
        _ value: UIImage,
        forKey key: KeyedEncodingContainer.Key,
        as type: EncodingImageType = .png
    ) throws {
        var imageData: Data?

        switch type {
            case .png:
                imageData = value.pngData()
            case .jpeg(let quality):
                imageData = value.jpegData(compressionQuality: quality)
        }

        guard let data = imageData else {
            throw EncodingError.invalidValue(value, .init(
                codingPath: [],
                debugDescription: "Failed to convert UIImage instance to Data.")
            )
        }

        try encode(data, forKey: key)
    }
}

extension KeyedDecodingContainer {
    public func decode(_ type: UIImage.Type, forKey key: KeyedDecodingContainer.Key) throws -> UIImage {
        let imageData = try decode(Data.self, forKey: key)

        guard let image = UIImage(data: imageData) else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Failed to create UIImage instance.")
        }

        return image
    }
}

extension SingleValueEncodingContainer {
    /// Encodes a single value of the given type.
    ///
    /// - Parameter value: The value to encode.
    /// - Throws: `EncodingError.invalidValue` if the given value is invalid in
    ///   the current context for this format.
    /// - Precondition: May not be called after a previous `self.encode(_:)`
    ///   call.
    public mutating func encode(_ value: UIImage, as type: EncodingImageType = .png) throws {
        var imageData: Data?

        switch type {
            case .png:
                imageData = value.pngData()
            case .jpeg(let quality):
                imageData = value.jpegData(compressionQuality: quality)
        }

        guard let data = imageData else {
            throw EncodingError.invalidValue(value, .init(
                codingPath: [],
                debugDescription: "Failed to convert UIImage instance to Data.")
            )
        }

        try encode(data)
    }
}

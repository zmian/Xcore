//
// Xcore
// Copyright © 2015 Xcore
// MIT license, see LICENSE file for details
//

import UIKit

extension Bundle {
    /// Method for creating or retrieving bundle instances.
    public static var xcore: Bundle {
        .init(for: DynamicTableView.self)
    }
}

public struct ImageAssetIdentifier: RawRepresentable, CustomStringConvertible, Equatable {
    public let rawValue: String
    public let bundle: Bundle

    /// A convenience initializer for `.xcassets` resource in the `.main` bundle.
    ///
    /// - Parameter rawValue: The name of the resource in `.xcassets`.
    public init(rawValue: String) {
        self.rawValue = rawValue
        self.bundle = .main
    }

    /// An initializer for `.xcassets` resource in the given `bundle`.
    ///
    /// - Parameters:
    ///   - rawValue: The name of the resource in `.xcassets`.
    ///   - bundle: The bundle for the `.xcassets`.
    public init(rawValue: String, bundle: Bundle) {
        self.rawValue = rawValue
        self.bundle = bundle
    }

    public var description: String {
        rawValue
    }
}

extension ImageAssetIdentifier: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension ImageAssetIdentifier: ImageRepresentable {
    public var imageSource: ImageSourceType {
        .url(rawValue)
    }
}

// MARK: - Convenience Extensions

extension UIImage {
    public convenience init(assetIdentifier: ImageAssetIdentifier) {
        self.init(named: assetIdentifier.rawValue, in: assetIdentifier.bundle, compatibleWith: nil)!
    }

    public static func tinted(assetIdentifier: ImageAssetIdentifier, tintColor: UIColor, renderingMode: UIImage.RenderingMode = .alwaysOriginal) -> UIImage {
        return UIImage(assetIdentifier: assetIdentifier).tintColor(tintColor).withRenderingMode(renderingMode)
    }
}

extension UIImageView {
    public convenience init(assetIdentifier: ImageAssetIdentifier) {
        self.init()
        setImage(assetIdentifier) { [weak self] image in
            guard let strongSelf = self else { return }
            strongSelf.image = image
        }
    }
}

extension TargetActionBlockRepresentable where Self: UIBarButtonItem {
    public init(assetIdentifier: ImageAssetIdentifier, accessibilityIdentifier: String? = nil, _ handler: ((_ sender: Self) -> Void)? = nil) {
        self.init(image: UIImage(assetIdentifier: assetIdentifier), handler)
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

extension ControlTargetActionBlockRepresentable where Self: UIButton {
    public init(assetIdentifier: ImageAssetIdentifier, accessibilityIdentifier: String? = nil, _ handler: ((_ sender: Self) -> Void)? = nil) {
        self.init(image: UIImage(assetIdentifier: assetIdentifier), handler)
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

/// A convenience function to get resource.
public func r(_ assetIdentifier: ImageAssetIdentifier) -> ImageAssetIdentifier {
    return assetIdentifier
}

// MARK: - Xcore Buit-in Assets

extension ImageAssetIdentifier {
    private static func propertyName(_ name: String = #function) -> Self {
        .init(rawValue: name, bundle: .xcore)
    }

    // MARK: Private
    static var collectionViewCellDeleteIcon: Self { propertyName() }
    static var reorderTableViewCellShadowTop: Self { propertyName() }
    static var reorderTableViewCellShadowBottom: Self { propertyName() }

    // MARK: Carets
    static var caretDirectionUp: Self { propertyName() }
    static var caretDirectionDown: Self { propertyName() }
    static var caretDirectionBack: Self { propertyName() }
    static var caretDirectionForward: Self { propertyName() }

    // MARK: Shared UI Elements
    public static var closeIcon: Self { propertyName() }
    public static var closeIconFilled: Self { propertyName() }

    public static var disclosureIndicator: Self { propertyName() }
    public static var disclosureIndicatorFilled: Self { propertyName() }

    /// Launch screen view uses this to automatically display the launch screen
    /// icon. This must be present in `.main` bundle before using the
    /// `LaunchScreenView`.
    public static var launchScreenIcon: Self { #function }

    // MARK: Navigation

    /// Icon used to replace navigation bar back arrow
    public static var navigationBarBackArrow: Self { propertyName() }
    public static var navigationBackArrow: Self { propertyName() }
    public static var navigationForwardArrow: Self { propertyName() }

    // MARK: Arrows
    public static var arrowRightIcon: Self { propertyName() }
    public static var arrowLeftIcon: Self { propertyName() }

    public static var filterSelectionIndicatorArrowIcon: Self { propertyName() }
    public static var info: Self { propertyName() }
    public static var locationIcon: Self { propertyName() }
    public static var searchIcon: Self { propertyName() }
    public static var validationErrorIcon: Self { propertyName() }
}

// MARK: - Xcore Buit-in Overridable Assets

extension ImageAssetIdentifier {
    // MARK: Checkmarks
    public static var checkmarkIcon = propertyName("checkmarkIcon")
    public static var checkmarkIconFilled = propertyName("checkmarkIconFilled")
    public static var checkmarkIconUnfilled = propertyName("checkmarkIconUnfilled")

    public static var moreIcon = propertyName("moreIcon")

    // MARK: Biometrics ID
    public static var biometricsFaceIDIcon = propertyName("biometricsFaceIDIcon")
    public static var biometricsTouchIDIcon = propertyName("biometricsTouchIDIcon")
}

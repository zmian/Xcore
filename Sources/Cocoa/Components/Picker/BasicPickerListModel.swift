//
// Xcore
// Copyright © 2019 Xcore
// MIT license, see LICENSE file for details
//

import Foundation

extension PickerList {
    /// A convenience method to display a picker with list of options
    /// that conforms to `PickerOptions` protocol.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// enum CompassPoint: Int, CaseIterable, PickerOptions {
    ///     case north, south, east, west
    /// }
    ///
    /// PickerList.present(selected: CompassPoint.allCases.first) { (option: CompassPoint) -> Void in
    ///     print("selected option:" option)
    /// }
    /// ```
    @discardableResult
    public static func present<T: PickerOptions>(
        selected option: T? = nil,
        configure: ((PickerList) -> Void)? = nil,
        _ handler: @escaping (_ option: T) -> Void
    ) -> PickerList {
        let model = BasicPickerListModel(selected: option) { option in
            handler(option)
        }

        let picker = PickerList(model: model)
        configure?(picker)
        picker.present()
        return picker
    }

    /// A convenience method to display a picker with list of options.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let options = ["Year", "Month", "Day"]
    /// PickerList.present(options: options, selected: options.first) { option in
    ///     print("selected option:" option)
    /// }
    /// ```
    @discardableResult
    public static func present(
        options: [String],
        selected option: String? = nil,
        _ handler: @escaping (_ option: String) -> Void
    ) -> PickerList {
        let model = BasicTextPickerListModel(options: options, selected: option) { option in
            handler(option)
        }

        let picker = PickerList(model: model)
        picker.present()
        return picker
    }

    /// A convenience method to display a picker with list of item.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let options = [
    ///     DynamicTableModel(title: "Year") { _ in }
    ///     DynamicTableModel(title: "Month") { _ in }
    ///     DynamicTableModel(title: "Day") { _ in }
    /// ]
    /// PickerList.present(options: options)
    /// ```
    @discardableResult
    public static func present(options: [DynamicTableModel], configure: PickerList.ConfigureBlock? = nil) -> PickerList {
        let model = BasicItemPickerListModel(options: options, configure: configure)
        let picker = PickerList(model: model)
        picker.present()
        return picker
    }
}

// MARK: - BasicPickerListModel

private final class BasicPickerListModel<T: PickerOptions>: PickerListModel {
    private let options: [T]
    private let selectedIndex: Int?
    private var selectionCallback: (T) -> Void

    init(selected option: T? = nil, handler: @escaping (T) -> Void) {
        self.options = T.allCases

        if let option = option, let index = options.firstIndex(of: option) {
            selectedIndex = index
        } else {
            selectedIndex = nil
        }

        selectionCallback = handler
    }

    private var checkmarkView: UIImageView {
        return UIImageView(assetIdentifier: .checkmarkIcon).apply {
            $0.frame.size = 20
            $0.tintColor = .appleGreen
            $0.isContentModeAutomaticallyAdjusted = true
        }
    }

    lazy var items: [DynamicTableModel] = {
        options.enumerated().map {
            DynamicTableModel(
                title: $0.element.description,
                image: $0.element.image,
                accessory: $0.offset == selectedIndex ? .custom(checkmarkView) : .none
            ) { [weak self] indexPath, _ in
                guard
                    let strongSelf = self,
                    let option = strongSelf.options.at(indexPath.item)
                else {
                    return
                }

                strongSelf.selectionCallback(option)
                DrawerScreen.dismiss()
            }
        }
    }()
}

// MARK: - BasicTextPickerListModel

private final class BasicTextPickerListModel: PickerListModel {
    private let options: [String]
    private let selectedIndex: Int?
    private var selectionCallback: (String) -> Void

    init(options: [String], selected option: String? = nil, handler: @escaping (String) -> Void) {
        self.options = options

        if let option = option, let index = options.firstIndex(of: option) {
            selectedIndex = index
        } else {
            selectedIndex = nil
        }

        selectionCallback = handler
    }

    private var checkmarkView: UIImageView {
        return UIImageView(assetIdentifier: .checkmarkIcon).apply {
            $0.frame.size = 20
            $0.tintColor = .appleGreen
            $0.isContentModeAutomaticallyAdjusted = true
        }
    }

    lazy var items: [DynamicTableModel] = {
        options.enumerated().map {
            DynamicTableModel(
                title: $0.element,
                accessory: $0.offset == selectedIndex ? .custom(checkmarkView) : .none
            ) { [weak self] indexPath, _ in
                guard
                    let strongSelf = self,
                    let option = strongSelf.options.at(indexPath.item)
                else {
                    return
                }

                strongSelf.selectionCallback(option)
                DrawerScreen.dismiss()
            }
        }
    }()

    func configure(indexPath: IndexPath, cell: DynamicTableViewCell, item: DynamicTableModel) {
        cell.titleLabel.textAlignment = .center
    }
}

// MARK: - BasicItemPickerListModel

private final class BasicItemPickerListModel: PickerListModel {
    private let _configure: PickerList.ConfigureBlock?
    let items: [DynamicTableModel]

    init(options: [DynamicTableModel], configure: PickerList.ConfigureBlock? = nil) {
        self.items = options
        self._configure = configure
    }

    func configure(indexPath: IndexPath, cell: DynamicTableViewCell, item: DynamicTableModel) {
        if item.isTextOnly {
            cell.titleLabel.textAlignment = .center
        }

        _configure?(indexPath, cell, item)
    }
}

extension PickerList {
    public typealias ConfigureBlock = (_ indexPath: IndexPath, _ cell: DynamicTableViewCell, _ item: DynamicTableModel) -> Void
}

//
// Xcore
// Copyright © 2016 Xcore
// MIT license, see LICENSE file for details
//

import UIKit

// MARK: - CarouselView

final public class CarouselView<Cell: CarouselViewCellType>: CustomCarouselView<Cell, CarouselViewModel<Cell.Model>> where Cell.Model: CarouselAccessibilitySupport {
    public func configure(items: [Cell.Model], currentIndex: Int = 0) {
        let model = CarouselViewModel<Cell.Model>(items: items)
        super.configure(model: model, currentIndex: currentIndex)
    }
}

// MARK: - CarouselViewModel

final public class CarouselViewModel<Model>: CarouselViewModelRepresentable where Model: CarouselAccessibilitySupport {
    public var items: [Model]

    public init(items: [Model]) {
        self.items = items
    }

    public func numberOfItems() -> Int {
        items.count
    }

    public func itemViewModel(index: Int) -> Model? {
        items.at(index)
    }

    public func accessibilityItem(index: Int) -> CarouselAccessibilityItem? {
        items.at(index)?.accessibilityItem(index: index)
    }
}

// MARK: - CustomCarouselView

open class CustomCarouselView<Cell: CarouselViewCellType, Model: CarouselViewModelRepresentable>: XCView where Cell.Model == Model.Model {
    private var heightConstraint: NSLayoutConstraint?
    private let carouselCollectionView = CarouselCollectionView<Cell, Model>()
    public let pageControl = PageControl(equalSizeDots: true)

    private lazy var stackView = UIStackView(arrangedSubviews: [
        carouselCollectionView,
        pageControl
    ]).apply {
        $0.axis = .vertical
        $0.spacing = pageControlSpacing
        $0.alignment = .center
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins.bottom = .minimumPadding
    }

    /// The specific carousel style (e.g., infinite scroll or multiple items per
    /// page).
    ///
    /// The default value is `.default`.
    public var style: Style {
        get { carouselCollectionView.style }
        set { carouselCollectionView.style = newValue }
    }

    /// A boolean value indicating whether the accessibility is enabled for the
    /// carousel view.
    ///
    /// The default value is `true`.
    public var isCarouselAccessibilityEnabled = true

    /// A boolean value indicating whether auto scrolling behavior is enabled.
    ///
    /// The default value is `false`.
    public var isAutoScrollingEnabled: Bool {
        return carouselCollectionView.isAutoScrollingEnabled
    }

    /// A boolean value indicating whether the carousel view height is same as the
    /// height of the cell.
    ///
    /// The default value is `true`.
    public var isHeightDerivedFromCell = true {
        didSet {
            if isHeightDerivedFromCell {
                heightConstraint?.activate()
            } else {
                heightConstraint?.deactivate()
            }
        }
    }

    public var isPageControlHidden = false {
        didSet {
            pageControl.isHidden = isPageControlHidden
            stackView.layoutMargins.bottom = isPageControlHidden ? 0 : .minimumPadding
            stackView.spacing = isPageControlHidden ? 0 : pageControlSpacing
        }
    }

    public var pageControlSpacing: CGFloat = .defaultPadding {
        didSet {
            stackView.spacing = pageControlSpacing
        }
    }

    public var currentIndex: Int {
        carouselCollectionView.currentIndex
    }

    public var numberOfItems: Int {
        carouselCollectionView.viewModel?.numberOfItems() ?? 0
    }

    public var visibleCells: [Cell] {
        (carouselCollectionView.visibleCells as? [Cell]) ?? []
    }

    open var accessibilityElement: UIAccessibilityElement? {
        carouselAccessibilityElement
    }

    private var carouselAccessibilityElement: CarouselAccessibilityElement<Cell, Model>?
    private var _accessibilityElements: [Any]?

    open override var accessibilityElements: [Any]? {
        get {
            guard isCarouselAccessibilityEnabled else {
                return nil
            }

            guard _accessibilityElements == nil else {
                return _accessibilityElements
            }

            let carouselAccessibilityElement: CarouselAccessibilityElement<Cell, Model>

            if let existingAccessibilityElement = self.carouselAccessibilityElement {
                carouselAccessibilityElement = existingAccessibilityElement
            } else {
                carouselAccessibilityElement = CarouselAccessibilityElement(
                    accessibilityContainer: self,
                    carouselView: carouselCollectionView
                )
                carouselAccessibilityElement.accessibilityFrameInContainerSpace = stackView.frame
                self.carouselAccessibilityElement = carouselAccessibilityElement
            }

            _accessibilityElements = [carouselAccessibilityElement]
            return _accessibilityElements
        }
        set {
            guard isCarouselAccessibilityEnabled else {
                return
            }
            _accessibilityElements = newValue
        }
    }

    open override func commonInit() {
        addSubview(stackView)
        stackView.anchor.make {
            $0.edges.equalToSuperview()
        }

        carouselCollectionView.didScroll { [weak self] index, previousIndex, scrollView in
            guard let strongSelf = self else { return }
            strongSelf.pageControl.currentPage = index
            strongSelf.didScroll?(index, previousIndex, scrollView)
        }

        carouselCollectionView.didChangeCurrentItem { [weak self] index, item in
            guard let strongSelf = self else { return }
            strongSelf.pageControl.currentPage = index
            strongSelf.didChangeCurrentItem?(index, item)
        }

        carouselCollectionView.prefetch { [weak self] index in
            self?.prefetch?(index)
        }

        carouselCollectionView.anchor.make {
            $0.horizontally.equalToSuperview()
            heightConstraint = $0.height.equalTo(carouselCollectionView.height).constraints.first
        }

        addKVOObservers()
    }

    private var kvoToken: NSKeyValueObservation?
    private func addKVOObservers() {
        kvoToken = carouselCollectionView.observe(\.contentSize, options: [.old, .new]) { [weak self] collectionView, values in
            guard
                let strongSelf = self,
                collectionView.contentSize.height > 0,
                collectionView.contentSize.width > 0,
                values.oldValue != values.newValue
            else {
                return
            }

            strongSelf.didChangeContentSize?()
            strongSelf.kvoToken = nil
        }
    }

    deinit {
        #if DEBUG
            print("\(self) deinit")
        #endif
    }

    // MARK: - API

    open func cellForItem(at index: Int) -> Cell? {
        carouselCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? Cell
    }

    open func reloadData() {
        carouselCollectionView.reloadData()
    }

    open func setCurrentIndex(_ index: Int, animated: Bool = true, completion: (() -> Void)? = nil) {
        pageControl.currentPage = index
        carouselCollectionView.setCurrentIndex(index, animated: animated, completion: completion)
    }

    open func configure(model: Model, currentIndex: Int = 0) {
        carouselCollectionView.viewModel = model
        pageControl.isHidden = isPageControlHidden
        pageControl.numberOfPages = carouselCollectionView.numberOfPages
        setCurrentIndex(currentIndex, animated: false)
    }

    // MARK: - Hooks

    private var didChangeContentSize: (() -> Void)?
    open func didChangeContentSize(_ callback: @escaping () -> Void) {
        didChangeContentSize = callback
    }

    open func didSelectItem(_ callback: @escaping (_ index: Int, _ item: Cell.Model) -> Void) {
        carouselCollectionView.didSelectItem(callback)
    }

    private var didChangeCurrentItem: ((_ index: Int, _ item: Cell.Model) -> Void)?
    open func didChangeCurrentItem(_ callback: @escaping (_ index: Int, _ item: Cell.Model) -> Void) {
        didChangeCurrentItem = callback
    }

    private var didScroll: ((_ index: Int, _ previousIndex: Int, _ scrollView: UIScrollView) -> Void)?
    open func didScroll(_ callback: @escaping (_ index: Int, _ previousIndex: Int, _ scrollView: UIScrollView) -> Void) {
        didScroll = callback
    }

    open func didConfigure(_ callback: @escaping (_ index: Int, _ item: Cell.Model, _ cell: Cell) -> Void) {
        carouselCollectionView.didConfigure(callback)
    }

    private var prefetch: ((_ indexPath: Int) -> Void)?
    open func prefetch(_ callback: @escaping ((_ indexPath: Int) -> Void)) {
        prefetch = callback
    }
}

// MARK: - Autoscroll

extension CustomCarouselView {
    public func startAutoScrolling(_ interval: TimeInterval = 4) {
        carouselCollectionView.startAutoScrolling(interval)
    }

    public func stopAutoScrolling() {
        carouselCollectionView.stopAutoScrolling()
    }

    public func scrollToNextPage() {
        carouselCollectionView.scrollToNextPage()
    }

    public func scrollToPreviousPage() {
        carouselCollectionView.scrollToPreviousPage()
    }
}

// MARK: - Convenience

extension CustomCarouselView {
    public func setContentOffset(_ contentOffset: CGPoint, async: Bool) {
        guard async else {
            carouselCollectionView.contentOffset = contentOffset
            return
        }

        // Content offset will not change before the main run loop ends without queuing
        // it.
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.carouselCollectionView.contentOffset = contentOffset
        }
    }
}

// MARK: - CarouselAccessibilityElement

private final class CarouselAccessibilityElement<Cell: CarouselViewCellType, Model: CarouselViewModelRepresentable>: UIAccessibilityElement where Cell.Model == Model.Model {
    private weak var carouselCollectionView: CarouselCollectionView<Cell, Model>?

    init(accessibilityContainer: Any, carouselView: CarouselCollectionView<Cell, Model>) {
        carouselCollectionView = carouselView
        super.init(accessibilityContainer: accessibilityContainer)
    }

    private var accessibilityItem: CarouselAccessibilityItem? {
        guard let currentIndex = carouselCollectionView?.currentIndex else {
            return nil
        }

        return carouselCollectionView?.viewModel?.accessibilityItem(index: currentIndex)
    }

    override var accessibilityLabel: String? {
        get { accessibilityItem?.label }
        // swiftlint:disable:next unused_setter_value
        set { }
    }

    override var accessibilityValue: String? {
        get { accessibilityItem?.value }
        // swiftlint:disable:next unused_setter_value
        set { }
    }

    override var accessibilityTraits: UIAccessibilityTraits {
        get { .adjustable }
        set { super.accessibilityTraits = newValue }
    }

    override func accessibilityIncrement() {
        guard
            let currentIndex = carouselCollectionView?.currentIndex,
            let totalItems = carouselCollectionView?.numberOfItems,
            currentIndex < totalItems - 1
        else {
            return
        }

        carouselCollectionView?.scrollToNextPage()
    }

    override func accessibilityDecrement() {
        carouselCollectionView?.scrollToPreviousPage()
    }
}

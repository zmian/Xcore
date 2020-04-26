//
// Xcore
// Based on https://github.com/ortuman/ComposedDataSource
// Copyright © 2014 Xcore
// MIT license, see LICENSE file for details
//

import UIKit

open class XCTableViewComposedDataSource: XCTableViewDataSource, ExpressibleByArrayLiteral {
    private var dataSourceIndex = DataSourceIndex<XCTableViewDataSource>()

    open override weak var tableView: UITableView? {
        didSet {
            attachTableView(to: dataSources)
        }
    }

    open var dataSources: [XCTableViewDataSource] = [] {
        didSet {
            attachTableView(to: dataSources)
        }
    }

    public override init() {
        super.init()
    }

    public init(dataSources: [XCTableViewDataSource]) {
        super.init()
        self.dataSources = dataSources
        attachTableView(to: dataSources)
    }

    public required convenience init(arrayLiteral elements: XCTableViewDataSource...) {
        self.init(dataSources: elements)
    }

    // MARK: Public Interface

    /// Adds a new data source at the end of the collection.
    open func add(_ dataSource: XCTableViewDataSource) {
        attachTableView(to: [dataSource])
        dataSources.append(dataSource)
    }

    open func remove(_ dataSource: XCTableViewDataSource) {
        guard let index = dataSources.firstIndex(of: dataSource) else {
            return
        }

        dataSources.remove(at: index)
    }

    private func attachTableView(to dataSources: [XCTableViewDataSource]) {
        dataSources.forEach {
            $0.tableView = tableView
        }
    }
}

// MARK: UITableViewDataSource

extension XCTableViewComposedDataSource {
    open override func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSections = 0
        let dataSourcesCount = dataSources.count

        for i in 0..<dataSourcesCount {
            var dataSourceSections = 1
            let dataSource = dataSources[i]

            if dataSource.responds(to: #selector(self.numberOfSections(in:))) {
                dataSourceSections = dataSource.numberOfSections(in: tableView)
            }

            var localSection = 0

            while dataSourceSections > 0 {
                dataSources[i].globalSection = i
                dataSourceIndex[numberOfSections] = (dataSources[i], localSection)
                localSection += 1
                numberOfSections += 1
                dataSourceSections -= 1
            }
        }

        return numberOfSections
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (dataSource, localSection) = dataSourceIndex[section]
        return dataSource.tableView(tableView, numberOfRowsInSection: localSection)
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (dataSource, localSection) = dataSourceIndex[indexPath.section]
        let localIndexPath = IndexPath(row: indexPath.row, section: localSection)
        return dataSource.tableView(tableView, cellForRowAt: localIndexPath)
    }

    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (dataSource, localSection) = dataSourceIndex[section]
        return dataSource.tableView(tableView, titleForHeaderInSection: localSection)
    }

    open override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let (dataSource, localSection) = dataSourceIndex[section]
        return dataSource.tableView(tableView, titleForFooterInSection: localSection)
    }

    open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let (dataSource, localSection) = dataSourceIndex[section]
        return dataSource.tableView(tableView, viewForHeaderInSection: localSection)
    }

    open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let (dataSource, localSection) = dataSourceIndex[section]
        return dataSource.tableView(tableView, viewForFooterInSection: localSection)
    }
}

// MARK: UITableViewDataSource

extension XCTableViewComposedDataSource {
    open override func heightForRow(at indexPath: IndexPath) -> CGFloat {
        let (dataSource, localSection) = dataSourceIndex[indexPath.section]
        let localIndexPath = IndexPath(row: indexPath.row, section: localSection)
        return dataSource.heightForRow(at: localIndexPath)
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (dataSource, localSection) = dataSourceIndex[indexPath.section]
        let localIndexPath = IndexPath(row: indexPath.row, section: localSection)
        dataSource.tableView(tableView, didSelectRowAt: localIndexPath)
    }

    open override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let (dataSource, localSection) = dataSourceIndex[indexPath.section]
        let localIndexPath = IndexPath(row: indexPath.row, section: localSection)
        dataSource.tableView(tableView, willDisplay: cell, forRowAt: localIndexPath)
    }

    open override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let (dataSource, localSection) = dataSourceIndex[indexPath.section]
        let localIndexPath = IndexPath(row: indexPath.row, section: localSection)
        dataSource.tableView(tableView, didEndDisplaying: cell, forRowAt: localIndexPath)
    }

    // Header and Footer

    open override func heightForHeaderInSection(_ section: Int) -> CGFloat {
        let (dataSource, localSection) = dataSourceIndex[section]
        return dataSource.heightForHeaderInSection(localSection)
    }

    open override func heightForFooterInSection(_ section: Int) -> CGFloat {
        let (dataSource, localSection) = dataSourceIndex[section]
        return dataSource.heightForFooterInSection(localSection)
    }
}

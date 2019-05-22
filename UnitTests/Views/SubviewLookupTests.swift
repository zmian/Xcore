//
// SubviewLookupTests.swift
//
// Copyright © 2018 Zeeshan Mian
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import XCTest
@testable import Xcore

final class SubviewLookupTests: ViewControllerTestCase {
    func testSubview() {
        let searchBar = UISearchBar()
        view.addSubview(searchBar)
        searchBar.layoutIfNeeded()

        XCTAssertNotNil(searchBar.subview(withClass: UITextField.self))
        XCTAssertNotNil(searchBar.subview(withClassName: "UISearchBarTextField"))

        XCTAssertNil(searchBar.subview(withClass: UITextField.self, comparison: .typeOf))
        XCTAssertNotNil(searchBar.subview(withClass: UITextField.self, comparison: .kindOf))
        XCTAssertNotNil(searchBar.subview(withClassName: "UISearchBarTextField", comparison: .typeOf))
        XCTAssertNotNil(searchBar.subview(withClassName: "UISearchBarTextField", comparison: .kindOf))
    }

    func testSearchBar() {
        let searchBar = UISearchBar()
        view.addSubview(searchBar)
        searchBar.layoutIfNeeded()

        XCTAssertNotNil(searchBar.textField)
        searchBar.placeholder = "Hello, World!"
        XCTAssertEqual(searchBar.placeholder, "Hello, World!")
    }
}

//
// ArrayTests.swift
//
// Copyright © 2019 Xcore
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

final class ArrayTests: TestCase {
    func testSplitBy() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        let chunks = array.splitBy(5)
        let expected = [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10], [11, 12]]
        XCTAssertEqual(chunks, expected)
    }

    func testSortByPreferredOrder() {
        let preferredOrder = ["Z", "A", "B", "C", "D"]
        var alphabets = ["D", "C", "B", "A", "Z", "W"]
        alphabets.sort(by: preferredOrder)
        let expected = ["Z", "A", "B", "C", "D", "W"]
        XCTAssertEqual(alphabets, expected)
    }

    func testSortedByPreferredOrder() {
        let preferredOrder = ["Z", "A", "B", "C", "D"]
        let alphabets = ["D", "C", "B", "A", "Z", "W"]
        let sorted = alphabets.sorted(by: preferredOrder)
        let expected = ["Z", "A", "B", "C", "D", "W"]
        XCTAssertEqual(sorted, expected)
        XCTAssertNotEqual(sorted, alphabets)
    }

    func testRawValues() {
        let values = [
            SomeType(rawValue: "Hello"),
            SomeType(rawValue: "World"),
            SomeType(rawValue: "!")
        ]

        let expectedRawValues = [
            "Hello",
            "World",
            "!"
        ]

        XCTAssertEqual(values.rawValues, expectedRawValues)
    }

    func testContains() {
        let instances = [UIView(), UIImageView()]
        let result = instances.contains(any: [UIImageView.self, UILabel.self])
        XCTAssertEqual(result, true)
        XCTAssertEqual(instances.contains(any: [UILabel.self]), false)
    }

    func testRandomElement() {
        let values = [132, 2432, 35435, 455]
        let randomValue = values.randomElement()
        XCTAssert(values.contains(randomValue))
    }

    func testRandomElements() {
        let values = [132, 2432, 35435, 455]
        let randomValue1 = values.randomElements(count: 17)
        let randomValue2 = values.randomElements(count: 2)

        XCTAssertEqual(randomValue1.count, values.count)
        XCTAssertEqual(randomValue2.count, 2)
    }

    func testEmptyRandomElements() {
        let values: [Int] = []
        let randomValue1 = values.randomElements(count: 17)
        let randomValue2 = values.randomElements(count: 2)

        XCTAssertEqual(randomValue1.count, values.count)
        XCTAssertEqual(randomValue2.count, 0)
    }

    func testFirstElement() {
        let value: [Any] = ["232", 12, 2, 11.0, "hello"]
        let resultString = value.firstElement(type: String.self)
        let resultInt = value.firstElement(type: Int.self)
        let resultDouble = value.firstElement(type: Double.self)
        let resultCGFloat = value.firstElement(type: CGFloat.self)
        XCTAssertEqual(resultString!, "232")
        XCTAssertEqual(resultInt!, 12)
        XCTAssertEqual(resultDouble!, 11)
        XCTAssertNil(resultCGFloat)
    }

    func testLastElement() {
        let value: [Any] = ["232", 12, 2, 11.0, "hello"]
        let resultString = value.lastElement(type: String.self)
        let resultInt = value.lastElement(type: Int.self)
        let resultDouble = value.lastElement(type: Double.self)
        let resultCGFloat = value.lastElement(type: CGFloat.self)
        XCTAssertEqual(resultString!, "hello")
        XCTAssertEqual(resultInt!, 2)
        XCTAssertEqual(resultDouble!, 11)
        XCTAssertNil(resultCGFloat)
    }

    func testFirstIndex() {
        let tag1View = UIView().apply { $0.tag = 1 }
        let tag2View = UIView().apply { $0.tag = 2 }

        let tag1Label = UILabel().apply { $0.tag = 1 }
        let tag2Label = UILabel().apply { $0.tag = 2 }

        let value: [NSObject] = [NSString("232"), tag1View, tag2View, tag1Label, tag2Label, NSString("hello")]
        let resultNSString = value.firstIndex(of: NSString.self)
        let resultUIView = value.firstIndex(of: UIView.self)
        let resultUILabel = value.firstIndex(of: UILabel.self)
        let resultUIViewController = value.firstIndex(of: UIViewController.self)
        XCTAssertEqual(resultNSString!, 0)
        XCTAssertEqual(resultUIView!, 1)
        XCTAssertEqual(resultUILabel!, 3)
        XCTAssertNil(resultUIViewController)
    }

    func testLastIndex() {
        let tag1View = UIView().apply { $0.tag = 1 }
        let tag2View = UIView().apply { $0.tag = 2 }

        let tag1Label = UILabel().apply { $0.tag = 1 }
        let tag2Label = UILabel().apply { $0.tag = 2 }

        let value: [NSObject] = [NSString("232"), tag1View, tag2View, tag1Label, tag2Label, NSString("hello")]
        let resultNSString = value.lastIndex(of: NSString.self)
        let resultUIView = value.lastIndex(of: UIView.self)
        let resultUILabel = value.lastIndex(of: UILabel.self)
        let resultUIViewController = value.lastIndex(of: UIViewController.self)
        XCTAssertEqual(resultNSString!, 5)
        XCTAssertEqual(resultUIView!, 4) // UILabel is subclass of UIView
        XCTAssertEqual(resultUILabel!, 4)
        XCTAssertNil(resultUIViewController)
    }

    func testJoined() {
        let label1 = UILabel().apply {
            $0.text = "Hello"
        }

        let label2 = UILabel()

        let label3 = UILabel().apply {
            $0.text = " "
        }

        let button = UIButton().apply {
            $0.text = "World!"
        }

        let value = [label1.text, label2.text, label3.text, button.text].joined(separator: ", ")
        XCTAssertEqual(value, "Hello, World!")
    }
}

private struct SomeType: RawRepresentable {
    let rawValue: String
}

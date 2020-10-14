import XCTest
@testable import XMLWrangler

final class XMLElementContentElementTests: XCTestCase {
    func testExpressibleByStringLiteral() {
        let content1: XWElement.Content.Element = "test"
        if case .string(let str) = content1 {
            XCTAssertEqual(str, "test")
        } else {
            XCTFail("Content is not string!")
        }
    }

    func testAppendingString() {
        var content: XWElement.Content = []
        var content2: XWElement.Content = ["hello"]

        content.append(string: "_this")
        content2.append(string: " world")

        XCTAssertEqual(content, [.string("_this")])
        XCTAssertEqual(content2, [.string("hello world")])
    }

    func testAppendingObject() {
        var content: XWElement.Content = []
        let child = XWElement(name: "_this")

        content.append(element: child)

        XCTAssertEqual(content, [.element(child)])
    }

    func testAppendingContentOfSequence() {
        var content: XWElement.Content = []
        let child1 = XWElement(name: "_this1")
        let child2 = XWElement(name: "_this2")
        let child3 = XWElement(name: "_this3")

        content.append(contentsOf: [child1, child2, child3])

        XCTAssertEqual(content, [.element(child1), .element(child2), .element(child3)])
    }

    func testAppendingElements() {
        var content: XWElement.Content = []
        let child1 = XWElement(name: "_this1")
        let child2 = XWElement(name: "_this2")
        let child3 = XWElement(name: "_this3")

        content.append(elements: child1, child2, child3)

        XCTAssertEqual(content, [.element(child1), .element(child2), .element(child3)])
    }

    func testCompression() {
        var content1: XWElement.Content = [
            .string("ABC"),
            .string("DEF"),
            .element(XWElement(name: "obj1")),
            .element(XWElement(name: "obj2")),
            .string("GHI"),
            .element(XWElement(name: "obj3")),
            .string("JKL"),
            .string("MNO"),
        ]
        let expectedContent1:XWElement.Content = [
            .string("ABCDEF"),
            .element(XWElement(name: "obj1")),
            .element(XWElement(name: "obj2")),
            .string("GHI"),
            .element(XWElement(name: "obj3")),
            .string("JKLMNO"),
        ]

        var content2: XWElement.Content = [
            .string("ABC"),
            .string("DEF"),
            .element(XWElement(name: "obj1")),
            .element(XWElement(name: "obj2")),
            .element(XWElement(name: "obj3")),
            .string("GHI"),
            .element(XWElement(name: "obj4")),
            .element(XWElement(name: "obj5")),
            .string("JKL"),
            .string("MNO"),
            .string("PQR"),
            .element(XWElement(name: "obj6")),
            .element(XWElement(name: "obj7")),
        ]
        let expectedContent2: XWElement.Content = [
            .string("ABCDEF"),
            .element(XWElement(name: "obj1")),
            .element(XWElement(name: "obj2")),
            .element(XWElement(name: "obj3")),
            .string("GHI"),
            .element(XWElement(name: "obj4")),
            .element(XWElement(name: "obj5")),
            .string("JKLMNOPQR"),
            .element(XWElement(name: "obj6")),
            .element(XWElement(name: "obj7")),
        ]

        let compressed1 = content1.compressed()
        content1.compress()
        let compressed2 = content2.compressed()
        content2.compress()

        XCTAssertEqual(content1, expectedContent1)
        XCTAssertEqual(content2, expectedContent2)
        XCTAssertEqual(content1, compressed1)
        XCTAssertEqual(content2, compressed2)
    }

    func testInternalHelpers() {
        let strContent = XWElement.Content.Element.string("ABC")
        let elemtContent = XWElement.Content.Element.element(XWElement(name: "some_element"))

        XCTAssertTrue(strContent.isString)
        XCTAssertFalse(strContent.isElement)
        XCTAssertEqual(strContent.string, "ABC")
        XCTAssertNil(strContent.element)
        XCTAssertFalse(elemtContent.isString)
        XCTAssertTrue(elemtContent.isElement)
        XCTAssertNil(elemtContent.string)
        XCTAssertEqual(elemtContent.element, XWElement(name: "some_element"))
    }
}

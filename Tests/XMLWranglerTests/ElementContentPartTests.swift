import XCTest
@testable import XMLWrangler

final class ElementContentPartTests: XCTestCase {
    func testExpressibleByStringLiteral() {
        let content1: Element.Content.Element = "test"
        if case .string(let str) = content1 {
            XCTAssertEqual(str, "test")
        } else {
            XCTFail("Content is not string!")
        }
    }

    func testAppendingString() {
        var content: Element.Content = []
        var content2: Element.Content = ["hello"]

        content.append(string: "_this")
        content2.append(string: " world")

        XCTAssertEqual(content, [.string("_this")])
        XCTAssertEqual(content2, [.string("hello world")])
    }

    func testAppendingObject() {
        var content: Element.Content = []
        let child = Element(name: "_this")

        content.append(object: child)

        XCTAssertEqual(content, [.object(child)])
    }

    func testAppendingContentOfSequence() {
        var content: Element.Content = []
        let child1 = Element(name: "_this1")
        let child2 = Element(name: "_this2")
        let child3 = Element(name: "_this3")

        content.append(contentsOf: [child1, child2, child3])

        XCTAssertEqual(content, [.object(child1), .object(child2), .object(child3)])
    }

    func testAppendingObjects() {
        var content: Element.Content = []
        let child1 = Element(name: "_this1")
        let child2 = Element(name: "_this2")
        let child3 = Element(name: "_this3")

        content.append(objects: child1, child2, child3)

        XCTAssertEqual(content, [.object(child1), .object(child2), .object(child3)])
    }

    func testCompression() {
        var content1: Element.Content = [
            .string("ABC"),
            .string("DEF"),
            .object(Element(name: "obj1")),
            .object(Element(name: "obj2")),
            .string("GHI"),
            .object(Element(name: "obj3")),
            .string("JKL"),
            .string("MNO"),
        ]
        let expectedContent1: Element.Content = [
            .string("ABCDEF"),
            .object(Element(name: "obj1")),
            .object(Element(name: "obj2")),
            .string("GHI"),
            .object(Element(name: "obj3")),
            .string("JKLMNO"),
        ]

        var content2: Element.Content = [
            .string("ABC"),
            .string("DEF"),
            .object(Element(name: "obj1")),
            .object(Element(name: "obj2")),
            .object(Element(name: "obj3")),
            .string("GHI"),
            .object(Element(name: "obj4")),
            .object(Element(name: "obj5")),
            .string("JKL"),
            .string("MNO"),
            .string("PQR"),
            .object(Element(name: "obj6")),
            .object(Element(name: "obj7")),
        ]
        let expectedContent2: Element.Content = [
            .string("ABCDEF"),
            .object(Element(name: "obj1")),
            .object(Element(name: "obj2")),
            .object(Element(name: "obj3")),
            .string("GHI"),
            .object(Element(name: "obj4")),
            .object(Element(name: "obj5")),
            .string("JKLMNOPQR"),
            .object(Element(name: "obj6")),
            .object(Element(name: "obj7")),
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
        let strContent = Element.Content.Element.string("ABC")
        let objContent = Element.Content.Element.object(Element(name: "some_element"))

        XCTAssertTrue(strContent.isString)
        XCTAssertFalse(strContent.isObject)
        XCTAssertEqual(strContent.string, "ABC")
        XCTAssertNil(strContent.object)
        XCTAssertFalse(objContent.isString)
        XCTAssertTrue(objContent.isObject)
        XCTAssertNil(objContent.string)
        XCTAssertEqual(objContent.object, Element(name: "some_element"))
    }
}

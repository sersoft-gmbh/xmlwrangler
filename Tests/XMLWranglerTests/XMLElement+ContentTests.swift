import XCTest
@testable import XMLWrangler

final class XMLElement_ContentTests: XCTestCase {
    private typealias Content = XWElement.Content

    func testContentElementDescriptions() {
        let strPart = Content.Element.string("abc")
        let elemPart = Content.Element.element(XWElement(name: "test"))
        XCTAssertEqual(strPart.description, "StringPart(abc)")
        XCTAssertEqual(strPart.debugDescription, "StringPart { abc }")
        XCTAssertEqual(elemPart.description, "Element(test)")
        XCTAssertEqual(elemPart.debugDescription, "Element {\n\(XWElement(name: "test").debugDescription)\n}")
    }

    func testContentElementInitializers() {
        let strPart: Content.Element = "str"
        let elemPart: Content.Element = .init(xml: XWElement(name: "abc"))
        XCTAssertEqual(strPart, .string("str"))
        XCTAssertEqual(elemPart, .element(XWElement(name: "abc")))
    }

    func testInitialization() {
        XCTAssertTrue(Content().storage.isEmpty)
        XCTAssertEqual(([.string("string"), .element(.init(name: "elem"))] as Content).storage,
                       [.string("string"), .element(.init(name: "elem"))])
    }

    func testDescriptions() {
        let content: Content = ["strContent", .element(.init(name: "test-element"))]
        XCTAssertEqual(content.description, content.storage.description)
        XCTAssertEqual(content.debugDescription, content.storage.debugDescription)
    }

    func testMutableCollectionConformance() {
        var content: Content = [.string("string"), .element(.init(name: "elem"))]
        XCTAssertEqual(content.startIndex, content.storage.startIndex)
        XCTAssertEqual(content.endIndex, content.storage.endIndex)
        XCTAssertEqual(content.underestimatedCount, content.storage.underestimatedCount)
        XCTAssertEqual(content.count, content.storage.count)
        XCTAssertEqual(content.isEmpty, content.storage.isEmpty)
        XCTAssertEqual(content.isEmpty, content.storage.isEmpty)
        XCTAssertEqual(content.index(after: content.startIndex), 
                       content.storage.index(after: content.storage.startIndex))
        XCTAssertEqual(content[content.startIndex], content.storage[content.storage.startIndex])
        content[content.startIndex] = .element(.init(name: "otherElem"))
        XCTAssertEqual(content.storage[content.storage.startIndex], .element(.init(name: "otherElem")))
    }

    func testBidirectionalCollectionConformance() {
        let content: Content = ["bidi"]
        XCTAssertEqual(content.index(before: content.endIndex), 
                       content.storage.index(before: content.storage.endIndex))
    }

    func testRandomAccessCollectionConformance() {
        let content: Content = ["random", "access", "collection"]
        XCTAssertEqual(content.index(content.startIndex, offsetBy: 2),
                       content.storage.index(content.storage.startIndex, offsetBy: 2))
        XCTAssertEqual(content.distance(from: content.startIndex, to: content.endIndex),
                       content.storage.distance(from: content.storage.startIndex, to: content.storage.endIndex))
    }

    func testRangeReplacableCollectionConformance() {
        var content: Content = ["range", "replacable", "collection"]
        var storage = content.storage
        content.replaceSubrange(0..<2, with: ["r", "r"])
        storage.replaceSubrange(0..<2, with: ["r", "r"])
        XCTAssertEqual(content.storage, storage)
    }

    func testExpressibleByXMLElementConformance() {
        XCTAssertEqual(Content(xml: .init(name: "elem")).storage, [.element(.init(name: "elem"))])
    }

    func testExpressibleByStringLiteralConformance() {
        XCTAssertEqual(("test" as Content).storage, [.string("test")])
    }

    func testExpressibleByStringInterpolationConformance() {
        struct Convertible: XMLElementConvertible {
            let xml: XWElement
        }

        let elem1 = XWElement(name: "testElement")
        let elem2 = XWElement(name: "test2", elements: elem1)
        let contents: Content.Storage = [.string("some string"), .element(elem1)]
        let testString = "some_text"
        let c1: Content = "literal\(elem1)\(testString)convertible:\(Convertible(xml: elem2))"
        XCTAssertEqual(c1.storage, [.string("literal"), .element(elem1), .string(testString + "convertible:"), .element(elem2)])
        let c2: Content = "whatever \(contents) empty: \(contentOf: elem1)"
        XCTAssertEqual(c2.storage, [.string("whatever some string"), .element(elem1), .string(" empty: ")])
        let c3: Content = "\(.element(elem1), .string("let's see"))"
        XCTAssertEqual(c3.storage, [.element(elem1), .string("let's see")])
        let c4: Content = "some text \(c3) and more text"
        XCTAssertEqual(c4.storage, [.string("some text "), .element(elem1), .string("let's see and more text")])
        let c5: Content = "contents: \(contentOf: elem2) here"
        XCTAssertEqual(c5.storage, [.string("contents: "), .element(elem1), .string(" here")])
    }
}

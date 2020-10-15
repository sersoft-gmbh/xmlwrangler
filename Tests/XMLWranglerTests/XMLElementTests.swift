import XCTest
import XMLWrangler

final class XMLElementTests: XCTestCase {
    func testInitialization() {
        let allDefaults = XWElement(name: "test")
        let withAttrs = XWElement(name: "test", attributes: ["test": "test"])
        let withContentNormal = XWElement(name: "test", attributes: ["test": "test"], content: ["test"])
        let withContentVariadic = XWElement(name: "test", attributes: ["test": "test"], content: "test")
        let withContentVariadicNoAttrs = XWElement(name: "test", content: .string("test"))
        let withElements = XWElement(name: "test", attributes: ["test": "test"], elements: [XWElement(name: "test")])
        let withElementsNoAttrs = XWElement(name: "test", elements: [XWElement(name: "test")])
        let withVariadicElements = XWElement(name: "test", attributes: ["test": "test"], elements: XWElement(name: "test"))
        let withVariadicElementsNoAttrs = XWElement(name: "test", elements: XWElement(name: "test"))
        let withStringContent = XWElement(name: "test", attributes: ["test": "test"], stringContent: "test")
        let withStringContentNoAttrs = XWElement(name: "test", stringContent: "test")

        XCTAssertEqual(allDefaults.name, "test")
        XCTAssertTrue(allDefaults.attributes.isEmpty)
        XCTAssertTrue(allDefaults.content.isEmpty)

        XCTAssertEqual(withAttrs.name, "test")
        XCTAssertEqual(withAttrs.attributes, ["test": "test"])
        XCTAssertTrue(withAttrs.content.isEmpty)

        XCTAssertEqual(withContentNormal.name, "test")
        XCTAssertEqual(withContentNormal.attributes, ["test": "test"])
        XCTAssertEqual(withContentNormal.content, [.string("test")])

        XCTAssertEqual(withContentVariadic.name, "test")
        XCTAssertEqual(withContentVariadic.attributes, ["test": "test"])
        XCTAssertEqual(withContentVariadic.content, [.string("test")])
        XCTAssertEqual(withContentVariadicNoAttrs.name, "test")
        XCTAssertTrue(withContentVariadicNoAttrs.attributes.isEmpty)
        XCTAssertEqual(withContentVariadicNoAttrs.content, [.string("test")])

        XCTAssertEqual(withElements.name, "test")
        XCTAssertEqual(withElements.attributes, ["test": "test"])
        XCTAssertEqual(withElements.content, [.element(XWElement(name: "test"))])
        XCTAssertEqual(withElementsNoAttrs.name, "test")
        XCTAssertTrue(withElementsNoAttrs.attributes.isEmpty)
        XCTAssertEqual(withElementsNoAttrs.content, [.element(XWElement(name: "test"))])

        XCTAssertEqual(withVariadicElements.name, "test")
        XCTAssertEqual(withVariadicElements.attributes, ["test": "test"])
        XCTAssertEqual(withVariadicElements.content, [.element(XWElement(name: "test"))])
        XCTAssertEqual(withVariadicElementsNoAttrs.name, "test")
        XCTAssertTrue(withVariadicElementsNoAttrs.attributes.isEmpty)
        XCTAssertEqual(withVariadicElementsNoAttrs.content, [.element(XWElement(name: "test"))])

        XCTAssertEqual(withStringContent.name, "test")
        XCTAssertEqual(withStringContent.attributes, ["test": "test"])
        XCTAssertEqual(withStringContent.content, [.string("test")])
        XCTAssertEqual(withStringContentNoAttrs.name, "test")
        XCTAssertTrue(withStringContentNoAttrs.attributes.isEmpty)
        XCTAssertEqual(withStringContentNoAttrs.content, [.string("test")])
    }

    func testIdentifier() {
        let element = XWElement(name: "test")
        XCTAssertEqual(element.id, element.name)
    }

    func testDescription() {
        let element = XWElement(name: "abc")
        XCTAssertEqual(element.description,
                       "XMLElement '\(element.name)' { \(element.attributes.count) attribute(s), \(element.content.count) content element(s) }")
    }

    func testDebugDescription() {
        let element = XWElement(name: "abc")
        XCTAssertEqual(element.debugDescription,
                       """
                       XMLElement '\(element.name.debugDescription)' {
                       attributes: \(element.attributes.debugDescription)
                       contents: \(element.content.debugDescription)
                       }
                       """)
    }

    func testXMLElementRepresentableCoformance() {
        let element = XWElement(name: "conv-test")
        XCTAssertEqual(XWElement(xml: element), element)
        XCTAssertEqual(element.xml, element)
    }
}

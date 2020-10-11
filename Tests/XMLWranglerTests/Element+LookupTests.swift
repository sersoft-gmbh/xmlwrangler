import XCTest
@testable import XMLWrangler

final class Element_LookupTests: XCTestCase {
    private struct StringInitializable: Equatable {
        let strValue: String
        init(str: String) { strValue = str }
    }

    private struct NotStringInitializable {
        init?(str: String) { nil }
    }

    private struct StringRepresentable: RawRepresentable, Equatable {
        let rawValue: String
        init(rawValue: String) { self.rawValue = rawValue }
    }

    private struct StringConvertible: LosslessStringConvertible, Equatable {
        let description: String
        init(_ description: String) { self.description = description }
    }

    private enum StringConvertibleAndRepresentable: RawRepresentable, LosslessStringConvertible, Equatable {
        case rawValue(String)
        case description(String)

        var stringValue: String {
            switch self {
            case .rawValue(let rawValue): return rawValue
            case .description(let description): return description
            }
        }

        var rawValue: String { stringValue }
        var description: String { stringValue }

        init(rawValue: String) { self = .rawValue(rawValue) }
        init(_ description: String) { self = .description(description) }
    }

    private struct StringRepresentableWithNotConvertibleRawValue: RawRepresentable, Equatable {
        struct RawValue: LosslessStringConvertible, Equatable {
            var description: String { "How on earth did you get here?" }
            init?(_ description: String) { nil }
        }
        let rawValue: RawValue
        init(rawValue: RawValue) { self.rawValue = rawValue }
    }

    private struct Expressible: ExpressibleByXMLElement {
        let element: Element

        init(xml: Element) throws {
            element = xml
        }
    }

    let sut = Element(name: "root", attributes: ["version": "2.3.4"], objects: [
        Element(name: "member", objects: [Element(name: "kind", content: "value")]),
        Element(name: "empty_member", attributes: ["active": "true", "id": "5"]),
        Element(name: "bigger", attributes: ["date": "2018-01-03"], objects: [
            Element(name: "children", objects: [
                Element(name: "child", objects: [
                    Element(name: "void"),
                    Element(name: "texts", content: [
                        .object(Element(name: "not_filled")),
                        .string("Huh?"),
                        .object(Element(name: "nested_text", content: "This is a text")),
                        .string("More text"),
                    ]),
                ]),
                Element(name: "child", content: "with not much content"),
                Element(name: "child"),
            ]),
            Element(name: "again_not_much", attributes: ["value": "124.56"]),
            Element(name: "stringy", content: [
                .string("Some text"),
                .object(Element(name: "an_object")),
                .string("More text"),
            ]),
            Element(name: "not_stringy"),
        ]),
        Element(name: "big", objects: [
            Element(name: "boring"),
            Element(name: "pets", objects: [
                Element(name: "dog", attributes: ["name": "Fifi"]),
                Element(name: "dog", attributes: ["name": "Fred"]),
                Element(name: "dog", attributes: ["name": "Pete"]),
                Element(name: "dog", attributes: ["name": "Max"]),
            ]),
        ]),
        Element(name: "simple", objects: Element(name: "simple_child")),
        Element(name: "repeating", attributes: ["repeat_count": "1"]),
        Element(name: "repeating", attributes: ["repeat_count": "2"]),
        Element(name: "repeating", attributes: ["repeat_count": "3"]),
        Element(name: "last"),
    ])

    let stringContentSUT = Element(name: "string_content", content: "we have content")
    let noStringContentSUT = Element(name: "no_string_content")

    // MARK: - Lookup
    // MARK: Single element
    func testExistingElementLookupAtPath() throws {
        let target = try sut.element(at: ["bigger", "children", "child", "void"])
        XCTAssertEqual(target, Element(name: "void"))
    }

    func testNonExistingElementLookupAtPath() {
        XCTAssertThrowsError(try sut.element(at: ["simple", "simple_child", "nope"])) {
            XCTAssert($0, is: .missingChild(element: "simple_child", childElementName: "nope"))
        }
    }

    func testExistingElementLookupAtVariadicPath() throws {
        let target = try sut.element(at: "bigger", "children", "child", "void")
        XCTAssertEqual(target, Element(name: "void"))
    }

    func testNonExistingElementLookupAtVariadicPath() {
        XCTAssertThrowsError(try sut.element(at: "simple", "simple_child", "nope")) {
            XCTAssert($0, is: .missingChild(element: "simple_child", childElementName: "nope"))
        }
    }

    // MARK: List of elements
    func testExistingElementsLookup() throws {
        let elements = try sut.elements(named: "repeating")
        XCTAssertEqual(elements.count, 3)
        XCTAssertEqual(elements, [Element(name: "repeating", attributes: ["repeat_count": "1"]),
                                  Element(name: "repeating", attributes: ["repeat_count": "2"]),
                                  Element(name: "repeating", attributes: ["repeat_count": "3"])])
    }

    func testNonExistingElementsLookup() throws {
        let elements = try sut.elements(named: "nope")
        XCTAssertTrue(elements.isEmpty)
    }


    // MARK: - Attributes
    // MARK: Retrieval
    func testExistingAttributeLookup() throws {
        let attribute = try sut.attribute(for: "version")
        XCTAssertEqual(attribute, "2.3.4")
    }

    func testNonExistingAttributeLookup() {
        XCTAssertThrowsError(try sut.attribute(for: "nope")) {
            XCTAssert($0, is: .missingAttribute(element: sut, key: "nope"))
        }
    }

    // MARK: Conversion
    func testNonExistingAttributeConversion() {
        XCTAssertThrowsError(try sut.convertedAttribute(for: "nope", converter: { StringInitializable(str: $0.rawValue) })) {
            XCTAssert($0, is: .missingAttribute(element: sut, key: "nope"))
        }
    }

    func testExistingAttributeConversion() throws {
        let attribute = try sut.convertedAttribute(for: "version", converter: { StringInitializable(str: $0.rawValue) })
        XCTAssertEqual(attribute, StringInitializable(str: "2.3.4"))
    }

    func testFailedExistingAttributeConversion() {
        XCTAssertThrowsError(try sut.convertedAttribute(for: "version", converter: { NotStringInitializable(str: $0.rawValue) })) {
            XCTAssert($0, is: .cannotConvertAttribute(element: sut, key: "version", type: NotStringInitializable.self))
        }
    }

    func testFailedRawRepresentableAttributeConversion() {
        XCTAssertThrowsError(try sut.convertedAttribute(for: "version", converter: { StringRepresentableWithNotConvertibleRawValue(rawValueDescription: $0.rawValue) })) {
            XCTAssert($0, is: .cannotConvertAttribute(element: sut, key: "version", type: StringRepresentableWithNotConvertibleRawValue.self))
        }
    }

    func testRawRepresentableAttributeConversion() throws {
        let attribute: StringRepresentable = try sut.convertedAttribute(for: "version")
        XCTAssertEqual(attribute, StringRepresentable(rawValue: "2.3.4"))
    }

    func testLosslessStringConvertibleAttributeConversion() throws {
        let attribute: StringConvertible = try sut.convertedAttribute(for: "version")
        XCTAssertEqual(attribute, StringConvertible("2.3.4"))
    }

    func testRawRepresentableLosslessStringConvertibleAttributeConversion() throws {
        let attribute: StringConvertibleAndRepresentable = try sut.convertedAttribute(for: "version")
        XCTAssertEqual(attribute, .rawValue("2.3.4"))
    }

    // MARK: - String Content
    // MARK: Retrieval
    func testNonExistingStringContentLookup() {
        XCTAssertThrowsError(try noStringContentSUT.stringContent()) {
            XCTAssert($0, is: .missingContent(element: noStringContentSUT))
        }
    }

    func testExistingStringContentLookup() throws {
        let content = try stringContentSUT.stringContent()
        XCTAssertEqual(content, "we have content")
    }

    // MARK: Conversion
    func testNonExistingStringContentConversion() {
        XCTAssertThrowsError(try noStringContentSUT.convertedStringContent(converter: StringInitializable.init)) {
            XCTAssert($0, is: .missingContent(element: noStringContentSUT))
        }
    }

    func testExistingStringContentConversion() throws {
        let content = try stringContentSUT.convertedStringContent(converter: StringInitializable.init)
        XCTAssertEqual(content, StringInitializable(str: "we have content"))
    }

    func testFailedExistingStringContentConversion() {
        XCTAssertThrowsError(try stringContentSUT.convertedStringContent(converter: NotStringInitializable.init)) {
            XCTAssert($0, is: .cannotConvertContent(element: stringContentSUT, content: "we have content", type: NotStringInitializable.self))
        }
    }

    func testFailedRawRepresentableExistingStringContentConversion() {
        XCTAssertThrowsError(try stringContentSUT.convertedStringContent(converter: StringRepresentableWithNotConvertibleRawValue.init)) {
            XCTAssert($0, is: .cannotConvertContent(element: stringContentSUT, content: "we have content", type: StringRepresentableWithNotConvertibleRawValue.self))
        }
    }

    func testRawRepresentableStringContentConversion() throws {
        let content: StringRepresentable = try stringContentSUT.convertedStringContent()
        XCTAssertEqual(content, StringRepresentable(rawValue: "we have content"))
    }

    func testLosslessStringConvertibleStringContentConversion() throws {
        let content: StringConvertible = try stringContentSUT.convertedStringContent()
        XCTAssertEqual(content, StringConvertible("we have content"))
    }

    func testRawRepresentableLosslessStringConvertibleStringContentConversion() throws {
        let content: StringConvertibleAndRepresentable = try stringContentSUT.convertedStringContent()
        XCTAssertEqual(content, .rawValue("we have content"))
    }

    func testConverting() {
        XCTAssertEqual(try sut.converted(to: Expressible.self).element, sut)
        XCTAssertEqual(try [sut, stringContentSUT, noStringContentSUT].converted(to: Expressible.self).map(\.element),
                       [sut, stringContentSUT, noStringContentSUT])
    }
}

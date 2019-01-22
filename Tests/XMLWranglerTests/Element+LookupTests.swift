import XCTest
@testable import XMLWrangler

final class Element_LookupTests: XCTestCase {
   private struct StringInitializable: Equatable {
      let strValue: String
      init(str: String) { strValue = str }
   }

   private struct NotStringInitializable {
      init?(str: String) { return nil }
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

      var rawValue: String { return stringValue }
      var description: String { return stringValue }

      init(rawValue: String) { self = .rawValue(rawValue) }
      init(_ description: String) { self = .description(description) }
   }

   private struct StringRepresentableWithNotConvertibleRawValue: RawRepresentable, Equatable {
      struct RawValue: LosslessStringConvertible, Equatable {
         var description: String { return "How on earth did you get here?" }
         init?(_ description: String) { return nil }
      }
      let rawValue: RawValue
      init(rawValue: RawValue) { self.rawValue = rawValue }
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
                  .string("More text")
                  ])
               ]),
            Element(name: "child", content: "with not much content"),
            Element(name: "child")
            ]),
         Element(name: "again_not_much", attributes: ["value": "124.56"]),
         Element(name: "stringy", content: [
            .string("Some text"),
            .object(Element(name: "an_object")),
            .string("More text")
            ]),
         Element(name: "not_stringy")
         ]),
      Element(name: "big", objects: [
         Element(name: "boring"),
         Element(name: "pets", objects: [
            Element(name: "dog", attributes: ["name": "Fifi"]),
            Element(name: "dog", attributes: ["name": "Fred"]),
            Element(name: "dog", attributes: ["name": "Pete"]),
            Element(name: "dog", attributes: ["name": "Max"])
            ])
         ]),
      Element(name: "simple", objects: [Element(name: "simple_child")]),
      Element(name: "repeating", attributes: ["repeat_count": "1"]),
      Element(name: "repeating", attributes: ["repeat_count": "2"]),
      Element(name: "repeating", attributes: ["repeat_count": "3"]),
      Element(name: "last")
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

   func testExistingElementsLookupAtPath() throws {
      let elements = try sut.elements(named: "dog", inElementAt: ["big", "pets"])
      XCTAssertEqual(elements.count, 4)
      XCTAssertEqual(elements, [Element(name: "dog", attributes: ["name": "Fifi"]),
                                Element(name: "dog", attributes: ["name": "Fred"]),
                                Element(name: "dog", attributes: ["name": "Pete"]),
                                Element(name: "dog", attributes: ["name": "Max"])])
   }

   func testNonExistingElementsLookupAtPath() throws {
      let elements = try sut.elements(named: "nope", inElementAt: ["big", "pets"])
      XCTAssertTrue(elements.isEmpty)
   }

   func testExistingElementsLookupAtVariadicPath() throws {
      let elements = try sut.elements(named: "dog", inElementAt: "big", "pets")
      XCTAssertEqual(elements.count, 4)
      XCTAssertEqual(elements, [Element(name: "dog", attributes: ["name": "Fifi"]),
                                Element(name: "dog", attributes: ["name": "Fred"]),
                                Element(name: "dog", attributes: ["name": "Pete"]),
                                Element(name: "dog", attributes: ["name": "Max"])])
   }

   func testNonExistingElementsLookupAtVariadicPath() throws {
      let elements = try sut.elements(named: "nope", inElementAt: "big", "pets")
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

   func testExistingAttributeLookupAtPath() throws {
      let attribute = try sut.attribute(for: "value", ofElementAt: ["bigger", "again_not_much"])
      XCTAssertEqual(attribute, "124.56")
   }

   func testNonExistingAttributeLookupAtPath() {
      XCTAssertThrowsError(try sut.attribute(for: "nope", ofElementAt: ["bigger", "again_not_much"])) {
         XCTAssert($0, is: .missingAttribute(element: Element(name: "again_not_much", attributes: ["value": "124.56"]), key: "nope"))
      }
   }

   func testExistingAttributeLookupAtVariadicPath() throws {
      let attribute = try sut.attribute(for: "value", ofElementAt: "bigger", "again_not_much")
      XCTAssertEqual(attribute, "124.56")
   }

   func testNonExistingAttributeLookupAtVariadicPath() {
      XCTAssertThrowsError(try sut.attribute(for: "nope", ofElementAt: "bigger", "again_not_much")) {
         XCTAssert($0, is: .missingAttribute(element: Element(name: "again_not_much", attributes: ["value": "124.56"]), key: "nope"))
      }
   }

   // MARK: Conversion
   func testNonExistingAttributeConversion() {
      XCTAssertThrowsError(try sut.convertedAttribute(for: "nope", converter: StringInitializable.init)) {
         XCTAssert($0, is: .missingAttribute(element: sut, key: "nope"))
      }
   }

   func testExistingAttributeConversion() throws {
      let attribute = try sut.convertedAttribute(for: "version", converter: StringInitializable.init)
      XCTAssertEqual(attribute, StringInitializable(str: "2.3.4"))
   }

   func testFailedExistingAttributeConversion() {
      XCTAssertThrowsError(try sut.convertedAttribute(for: "version", converter: NotStringInitializable.init)) {
         XCTAssert($0, is: .cannotConvertAttribute(element: sut, key: "version", type: NotStringInitializable.self))
      }
   }

   func testFailedRawRepresentableAttributeConversion() {
      XCTAssertThrowsError(try sut.convertedAttribute(for: "version", converter: StringRepresentableWithNotConvertibleRawValue.init)) {
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

   func testNonExistingAttributeConversionAtPath() {
      XCTAssertThrowsError(try sut.convertedAttribute(for: "nope", ofElementAt: ["bigger", "again_not_much"], converter: StringInitializable.init)) {
         XCTAssert($0, is: .missingAttribute(element: Element(name: "again_not_much", attributes: ["value": "124.56"]), key: "nope"))
      }
   }

   func testExistingAttributeConversionAtPath() throws {
      let attribute = try sut.convertedAttribute(for: "value", ofElementAt: ["bigger", "again_not_much"], converter: StringInitializable.init)
      XCTAssertEqual(attribute, StringInitializable(str: "124.56"))
   }

   func testFailedExistingAttributeConversionAtPath() {
      XCTAssertThrowsError(try sut.convertedAttribute(for: "value", ofElementAt: ["bigger", "again_not_much"], converter: NotStringInitializable.init)) {
         XCTAssert($0, is: .cannotConvertAttribute(element: Element(name: "again_not_much", attributes: ["value": "124.56"]), key: "value", type: NotStringInitializable.self))
      }
   }

   func testRawRepresentableAttributeConversionAtPath() throws {
      let attribute: StringRepresentable = try sut.convertedAttribute(for: "value", ofElementAt: ["bigger", "again_not_much"])
      XCTAssertEqual(attribute, StringRepresentable(rawValue: "124.56"))
   }

   func testLosslessStringConvertibleAttributeConversionAtPath() throws {
      let attribute: StringConvertible = try sut.convertedAttribute(for: "value", ofElementAt: ["bigger", "again_not_much"])
      XCTAssertEqual(attribute, StringConvertible("124.56"))
   }

   func testRawRepresentableLosslessStringConvertibleAttributeConversionAtPath() throws {
      let attribute: StringConvertibleAndRepresentable = try sut.convertedAttribute(for: "value", ofElementAt: ["bigger", "again_not_much"])
      XCTAssertEqual(attribute, .rawValue("124.56"))
   }

   func testNonExistingAttributeConversionAtVariadicPath() {
      XCTAssertThrowsError(try sut.convertedAttribute(for: "nope", ofElementAt: "bigger", "again_not_much", converter: StringInitializable.init)) {
         XCTAssert($0, is: .missingAttribute(element: Element(name: "again_not_much", attributes: ["value": "124.56"]), key: "nope"))
      }
   }

   func testExistingAttributeConversionAtVariadicPath() throws {
      let attribute = try sut.convertedAttribute(for: "value", ofElementAt: "bigger", "again_not_much", converter: StringInitializable.init)
      XCTAssertEqual(attribute, StringInitializable(str: "124.56"))
   }

   func testFailedExistingAttributeConversionAtVariadicPath() {
      XCTAssertThrowsError(try sut.convertedAttribute(for: "value", ofElementAt: "bigger", "again_not_much", converter: NotStringInitializable.init)) {
         XCTAssert($0, is: .cannotConvertAttribute(element: Element(name: "again_not_much", attributes: ["value": "124.56"]), key: "value", type: NotStringInitializable.self))
      }
   }

   func testRawRepresentableAttributeConversionAtVariadicPath() throws {
      let attribute: StringRepresentable = try sut.convertedAttribute(for: "value", ofElementAt: "bigger", "again_not_much")
      XCTAssertEqual(attribute, StringRepresentable(rawValue: "124.56"))
   }

   func testLosslessStringConvertibleAttributeConversionAtVariadicPath() throws {
      let attribute: StringConvertible = try sut.convertedAttribute(for: "value", ofElementAt: "bigger", "again_not_much")
      XCTAssertEqual(attribute, StringConvertible("124.56"))
   }

   func testRawRepresentableLosslessStringConvertibleAttributeConversionAtVariadicPath() throws {
      let attribute: StringConvertibleAndRepresentable = try sut.convertedAttribute(for: "value", ofElementAt: "bigger", "again_not_much")
      XCTAssertEqual(attribute, .rawValue("124.56"))
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

   func testNonExistingStringContentLookupAtPath() {
      XCTAssertThrowsError(try sut.stringContent(ofElementAt: ["bigger", "not_stringy"])) {
         XCTAssert($0, is: .missingContent(element: Element(name: "not_stringy")))
      }
   }

   func testExistingStringContentLookupAtPath() throws {
      let content = try sut.stringContent(ofElementAt: ["bigger", "stringy"])
      XCTAssertEqual(content, "Some textMore text")
   }

   func testNonExistingStringContentLookupAtVariadicPath() {
      XCTAssertThrowsError(try sut.stringContent(ofElementAt: "bigger", "not_stringy")) {
         XCTAssert($0, is: .missingContent(element: Element(name: "not_stringy")))
      }
   }

   func testExistingStringContentLookupAtVariadicPath() throws {
      let content = try sut.stringContent(ofElementAt: "bigger", "stringy")
      XCTAssertEqual(content, "Some textMore text")
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

   func testNonExistingStringContentConversionAtPath() {
      XCTAssertThrowsError(try sut.convertedStringContent(ofElementAt: ["bigger", "not_stringy"], converter: StringInitializable.init)) {
         XCTAssert($0, is: .missingContent(element: Element(name: "not_stringy")))
      }
   }

   func testExistingStringContentConversionAtPath() throws {
      let content = try sut.convertedStringContent(ofElementAt: ["bigger", "stringy"], converter: StringInitializable.init)
      XCTAssertEqual(content, StringInitializable(str: "Some textMore text"))
   }

   func testFailedExistingStringContentConversionAtPath() {
      XCTAssertThrowsError(try sut.convertedStringContent(ofElementAt: ["bigger", "stringy"], converter: NotStringInitializable.init)) {
         XCTAssert($0, is: .cannotConvertContent(element: Element(name: "stringy",
                                                                  content: [.string("Some text"),
                                                                            .object(Element(name: "an_object")),
                                                                            .string("More text")]),
                                                 content: "Some textMore text",
                                                 type: NotStringInitializable.self))
      }
   }

   func testRawRepresentableStringContentConversionAtPath() throws {
      let content: StringRepresentable = try sut.convertedStringContent(ofElementAt: ["bigger", "stringy"])
      XCTAssertEqual(content, StringRepresentable(rawValue: "Some textMore text"))
   }

   func testLosslessStringConvertibleStringContentConversionAtPath() throws {
      let content: StringConvertible = try sut.convertedStringContent(ofElementAt: ["bigger", "stringy"])
      XCTAssertEqual(content, StringConvertible("Some textMore text"))
   }

   func testRawRepresentableLosslessStringConvertibleStringContentConversionAtPath() throws {
      let content: StringConvertibleAndRepresentable = try sut.convertedStringContent(ofElementAt: ["bigger", "stringy"])
      XCTAssertEqual(content, .rawValue("Some textMore text"))
   }

   func testNonExistingStringContentConversionAtVariadicPath() {
      XCTAssertThrowsError(try sut.convertedStringContent(ofElementAt: "bigger", "not_stringy", converter: StringInitializable.init)) {
         XCTAssert($0, is: .missingContent(element: Element(name: "not_stringy")))
      }
   }

   func testExistingStringContentConversionAtVariadicPath() throws {
      let content = try sut.convertedStringContent(ofElementAt: "bigger", "stringy", converter: StringInitializable.init)
      XCTAssertEqual(content, StringInitializable(str: "Some textMore text"))
   }

   func testFailedExistingStringContentConversionAtVariadicPath() {
      XCTAssertThrowsError(try sut.convertedStringContent(ofElementAt: "bigger", "stringy", converter: NotStringInitializable.init)) {
         XCTAssert($0, is: .cannotConvertContent(element: Element(name: "stringy",
                                                                  content: [.string("Some text"),
                                                                            .object(Element(name: "an_object")),
                                                                            .string("More text")]),
                                                 content: "Some textMore text",
                                                 type: NotStringInitializable.self))
      }
   }

   func testRawRepresentableStringContentConversionAtVariadicPath() throws {
      let content: StringRepresentable = try sut.convertedStringContent(ofElementAt: "bigger", "stringy")
      XCTAssertEqual(content, StringRepresentable(rawValue: "Some textMore text"))
   }

   func testLosslessStringConvertibleStringContentConversionAtVariadicPath() throws {
      let content: StringConvertible = try sut.convertedStringContent(ofElementAt: "bigger", "stringy")
      XCTAssertEqual(content, StringConvertible("Some textMore text"))
   }

   func testRawRepresentableLosslessStringConvertibleStringContentConversionAtVariadicPath() throws {
      let content: StringConvertibleAndRepresentable = try sut.convertedStringContent(ofElementAt: "bigger", "stringy")
      XCTAssertEqual(content, .rawValue("Some textMore text"))
   }
}

import XCTest
@testable import XMLWrangler

final class ElementTests: XCTestCase {
   func testExpressibleByStringLiteral() {
      let element: Element = "test"
      XCTAssertEqual(element.name, "test")
   }

   func testEqualityCheck() {
      let elem1 = Element(name: "test")
      let elem2 = Element(name: "test")
      let elem3 = Element(name: "test", attributes: ["key": "value"])
      let elem4 = Element(name: "test", attributes: ["key": "value"])
      let elem5 = Element(name: "test", attributes: ["key": "value"], content: "whatever")

      XCTAssertEqual(elem1, elem2)
      XCTAssertEqual(elem3, elem4)
      XCTAssertNotEqual(elem1, elem3)
      XCTAssertNotEqual(elem4, elem5)
   }
   
   func testConvertingAttributes() {
      let attrs: Element.Attributes = [
         "key1": "str",
         "key2": "10",
         "key3": "12.5"
      ]
      let element = Element(name: "test", attributes: attrs)
      
      let extracted1: String? = element.convertedAttribute(for: "key1")
      let extracted2: Int? = element.convertedAttribute(for: "key2")
      let extracted3: Double? = element.convertedAttribute(for: "key3")
      let extracted4: Int? = element.convertedAttribute(for: "key1")
      let extracted5: Int? = element.convertedAttribute(for: "wrong_key")
      
      XCTAssertNotNil(extracted1)
      XCTAssertNotNil(extracted2)
      XCTAssertNotNil(extracted3)
      XCTAssertNil(extracted4)
      XCTAssertNil(extracted5)
      XCTAssertEqual(extracted1, "str")
      XCTAssertEqual(extracted2, 10)
      XCTAssertEqual(extracted3, 12.5)
   }

   static var allTests = [
      ("testExpressibleByStringLiteral", testExpressibleByStringLiteral),
      ("testEqualityCheck", testEqualityCheck),
      ("testConvertingAttributes", testConvertingAttributes),
   ]
}

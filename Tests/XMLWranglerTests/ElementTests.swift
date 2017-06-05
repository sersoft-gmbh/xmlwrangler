import XCTest
@testable import XMLWrangler

class ElementTests: XCTestCase {
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

   static var allTests = [
      ("testExpressibleByStringLiteral", testExpressibleByStringLiteral),
      ("testEqualityCheck", testEqualityCheck),
   ]
}

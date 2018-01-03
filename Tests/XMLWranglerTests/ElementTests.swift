import XCTest
@testable import XMLWrangler

final class ElementTests: XCTestCase {
   func testExpressibleByStringLiteral() {
      let element: Element = "test"
      XCTAssertEqual(element.name, .init(rawValue: "test"))
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

   func testAppendingString() {
      var element = Element(name: "test")
      var element2 = Element(name: "test2", content: "hello")

      element.append(string: "_this")
      element2.append(string: " world")

      XCTAssertEqual(element.content, [.string("_this")])
      XCTAssertEqual(element2.content, [.string("hello world")])
   }

   func testAppendingObject() {
      var element = Element(name: "test")
      let child = Element(name: "_this")

      element.append(object: child)

      XCTAssertEqual(element.content, [.object(child)])
   }

   func testAppendingContentOfSequence() {
      var element = Element(name: "test")
      let child1 = Element(name: "_this1")
      let child2 = Element(name: "_this2")
      let child3 = Element(name: "_this3")

      element.append(contentsOf: [child1, child2, child3])

      XCTAssertEqual(element.content, [.object(child1), .object(child2), .object(child3)])
   }

   func testAppendingObjects() {
      var element = Element(name: "test")
      let child1 = Element(name: "_this1")
      let child2 = Element(name: "_this2")
      let child3 = Element(name: "_this3")
      
      element.append(objects: child1, child2, child3)
      
      XCTAssertEqual(element.content, [.object(child1), .object(child2), .object(child3)])
   }

   static var allTests = [
      ("testExpressibleByStringLiteral", testExpressibleByStringLiteral),
      ("testEqualityCheck", testEqualityCheck),
      ("testAppendingString", testAppendingString),
      ("testAppendingObject", testAppendingObject),
      ("testAppendingContentOfSequence", testAppendingContentOfSequence),
      ("testAppendingObjects", testAppendingObjects),
   ]
}

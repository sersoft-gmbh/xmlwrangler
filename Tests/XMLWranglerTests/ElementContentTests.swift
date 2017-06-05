import XCTest
@testable import XMLWrangler

class ElementContentTests: XCTestCase {
   func testExpressibleByNilLiteral() {
      let content: Element.Content = nil
      if case .empty = content {} else {
         XCTFail("Content is not empty!")
      }
   }

   func testExpressibleByStringLiteral() {
      let content1: Element.Content = "test"
      let content2: Element.Content = ""
      if case .string(let str) = content1 {
         XCTAssertEqual(str, "test")
      } else {
         XCTFail("Content is not string!")
      }
      if case .empty = content2 {} else {
         XCTFail("Content is not empty!")
      }
   }

   func testExpressibleByArrayLiteral() {
      let elem1 = Element(name: "a")
      let elem2 = Element(name: "b", attributes: ["key": "value"])
      let content1: Element.Content = [elem1, elem2]
      let content2: Element.Content = []
      if case .objects(let objs) = content1 {
         XCTAssertEqual(objs, [elem1, elem2])
      } else {
         XCTFail("Content is not objects!")
      }
      if case .empty = content2 {} else {
         XCTFail("Content is not empty!")
      }
   }

   func testEqualityCheck() {
      let content1 = Element.Content.empty
      let content2 = Element.Content.empty

      let content3 = Element.Content.string("test1")
      let content4 = Element.Content.string("test1")
      let content5 = Element.Content.string("test2")

      let elem1 = Element(name: "test1")
      let elem2 = Element(name: "test2")

      let content6 = Element.Content.objects([elem1])
      let content7 = Element.Content.objects([elem1])
      let content8 = Element.Content.objects([elem2])

      XCTAssertEqual(content1, content2)
      XCTAssertEqual(content3, content4)
      XCTAssertEqual(content6, content7)
      XCTAssertNotEqual(content1, content3)
      XCTAssertNotEqual(content1, content6)
      XCTAssertNotEqual(content4, content5)
      XCTAssertNotEqual(content4, content6)
      XCTAssertNotEqual(content7, content8)
   }

   func testAppendingString() {
      var unconvertedContent = Element.Content.empty
      var convertedContent = Element.Content.empty
      var extendedContent = Element.Content.string("test")

      unconvertedContent.append(string: "_this")
      convertedContent.append(string: "_this", convertIfNecessary: true)
      extendedContent.append(string: "_this")

      if case .empty = unconvertedContent {} else {
         XCTFail("Content must not be converted!")
      }
      if case .string(let str) = convertedContent {
         XCTAssertEqual(str, "_this")
      } else {
         XCTFail("Content must be converted!")
      }
      if case .string(let str) = extendedContent {
         XCTAssertEqual("test_this", str)
      } else {
         XCTFail("This shouldn't happen. Did you initialize it wrong?")
      }
   }

   func testAppendingObject() {
      let elem1 = Element(name: "test1")
      let elem2 = Element(name: "test2")
      var unconvertedContent = Element.Content.empty
      var convertedContent = Element.Content.empty
      var extendedContent = Element.Content.objects([elem1])

      unconvertedContent.append(object: elem2)
      convertedContent.append(object: elem2, convertIfNecessary: true)
      extendedContent.append(object: elem2)

      if case .empty = unconvertedContent {} else {
         XCTFail("Content must not be converted!")
      }
      if case .objects(let objs) = convertedContent {
         XCTAssertEqual(objs, [elem2])
      } else {
         XCTFail("Content must be converted!")
      }
      if case .objects(let objs) = extendedContent {
         XCTAssertEqual(objs, [elem1, elem2])
      } else {
         XCTFail("This shouldn't happen. Did you initialize it wrong?")
      }
   }

   func testAppendingObjects() {
      let elem1 = Element(name: "test1")
      let elem2 = Element(name: "test2")
      let elem3 = Element(name: "test3")
      var unconvertedContent = Element.Content.empty
      var convertedContent = Element.Content.empty
      var extendedContent = Element.Content.objects([elem1])

      unconvertedContent.append(contentsOf: [elem2, elem3])
      convertedContent.append(contentsOf: [elem2, elem3], convertIfNecessary: true)
      extendedContent.append(contentsOf: [elem2, elem3])

      if case .empty = unconvertedContent {} else {
         XCTFail("Content must not be converted!")
      }
      if case .objects(let objs) = convertedContent {
         XCTAssertEqual(objs, [elem2, elem3])
      } else {
         XCTFail("Content must be converted!")
      }
      if case .objects(let objs) = extendedContent {
         XCTAssertEqual(objs, [elem1, elem2, elem3])
      } else {
         XCTFail("This shouldn't happen. Did you initialize it wrong?")
      }
   }

   static var allTests = [
      ("testExpressibleByStringLiteral", testExpressibleByStringLiteral),
      ("testExpressibleByNilLiteral", testExpressibleByNilLiteral),
      ("testExpressibleByArrayLiteral", testExpressibleByArrayLiteral),
      ("testEqualityCheck", testEqualityCheck),
      ("testAppendingString", testAppendingString),
      ("testAppendingObject", testAppendingObject),
      ("testAppendingObjects", testAppendingObjects)
   ]
}

import XCTest
@testable import XMLWrangler

final class ElementContent_LookupTests: XCTestCase {
   func testFindingObjectsShallow() {
      let string: [Element.Content] = [.string("testStr")]
      let source: [Element.Content] = [
         .object(Element(name: "test")),
         .object(Element(name: "test_something")),
         .object(Element(name: "whatever")),
         .object(Element(name: "test")),
         .object(Element(name: "is")),
         .object(Element(name: "here")),
         .object(Element(name: "test_something")),
         ]

      let stringResult = string.find(elementsNamed: "something")
      let cannotFind = source.find(elementsNamed: "not_existent")
      let testResult = source.find(elementsNamed: "test")
      let whateverResult = source.find(elementsNamed: "whatever")

      XCTAssertTrue(stringResult.isEmpty)
      XCTAssertTrue(cannotFind.isEmpty)
      XCTAssertEqual(testResult.count, 2)
      XCTAssertEqual(whateverResult.count, 1)
      XCTAssertEqual(testResult, ["test", "test"])
      XCTAssertEqual(whateverResult, ["whatever"])
   }

   func testFindingFirstObjectShallow() {
      let string: [Element.Content] = [.string("testStr")]
      let source: [Element.Content] = [
         .object(Element(name: "test", content: "value")),
         .object(Element(name: "test_something")),
         .object(Element(name: "whatever")),
         .object(Element(name: "test")),
         .object(Element(name: "is")),
         .object(Element(name: "here")),
         .object(Element(name: "test_something")),
         ]

      let stringResult = string.findFirst(elementNamed: "something")
      let cannotFind = source.findFirst(elementNamed: "not_existent")
      let testResult = source.findFirst(elementNamed: "test")
      let whateverResult = source.findFirst(elementNamed: "whatever")

      XCTAssertNil(stringResult)
      XCTAssertNil(cannotFind)
      XCTAssertNotNil(testResult)
      XCTAssertNotNil(whateverResult)
      XCTAssertEqual(testResult?.content, ["value"])
      XCTAssertTrue(whateverResult?.content.isEmpty ?? false)
   }

   func testFindingLastObjectShallow() {
      let string: [Element.Content] = [.string("testStr")]
      let source: [Element.Content] = [
         .object(Element(name: "test")),
         .object(Element(name: "test_something")),
         .object(Element(name: "whatever")),
         .object(Element(name: "test", content: "value")),
         .object(Element(name: "is")),
         .object(Element(name: "here")),
         .object(Element(name: "test_something")),
         ]

      let stringResult = string.findLast(elementNamed: "something")
      let cannotFind = source.findLast(elementNamed: "not_existent")
      let testResult = source.findLast(elementNamed: "test")
      let whateverResult = source.findLast(elementNamed: "whatever")

      XCTAssertNil(stringResult)
      XCTAssertNil(cannotFind)
      XCTAssertNotNil(testResult)
      XCTAssertNotNil(whateverResult)
      XCTAssertEqual(testResult?.content, ["value"])
      XCTAssertTrue(whateverResult?.content.isEmpty ?? false)
   }

   func testFindingObjectsRecursive() {
      let string: [Element.Content] = [.string("testStr")]
      let source: [Element.Content] = [
         .object(Element(name: "test_something",
                         objects: Element(name: "test", content: "value"))),
         .object(Element(name: "test_it")),
         .object(Element(name: "is", objects:
            Element(name: "add", objects:
               Element(name: "some", objects:
                  Element(name: "deeper"),
                       Element(name: "levels", objects:
                        Element(name: "deeper"),
                               Element(name: "whatever")
                  )
               ),
                    Element(name: "test"),
                    Element(name: "deeper")
            ),
                         Element(name: "deeper")
         )),
         .object(Element(name: "here")),
         .object(Element(name: "test_something")),
         ]

      let stringResult = string.find(elementsNamed: "something", recursive: true)
      let cannotFind = source.find(elementsNamed: "not_existent", recursive: true)
      let testResult = source.find(elementsNamed: "test", recursive: true)
      let whateverResult = source.find(elementsNamed: "whatever", recursive: true)

      XCTAssertTrue(stringResult.isEmpty)
      XCTAssertTrue(cannotFind.isEmpty)
      XCTAssertEqual(testResult.count, 2)
      XCTAssertEqual(whateverResult.count, 1)
      XCTAssertEqual(testResult, [Element(name: "test", content: "value"), "test"])
      XCTAssertEqual(whateverResult, ["whatever"])
   }

   func testFindingFirstObjectRecursive() {
      let string: [Element.Content] = [.string("testStr")]
      let source: [Element.Content] = [
         .object(Element(name: "test_something",
                         objects: Element(name: "test", content: "value"))),
         .object(Element(name: "test_it")),
         .object(Element(name: "is", objects:
            Element(name: "add", objects:
               Element(name: "some", objects:
                  Element(name: "deeper"),
                       Element(name: "levels", objects:
                        Element(name: "deeper"),
                               Element(name: "whatever", content: "deep down")
                  )
               ),
                    Element(name: "test"),
                    Element(name: "whatever", content: "not so deep"),
                    Element(name: "deeper")
            ),
                         Element(name: "deeper"))
         ),
         .object(Element(name: "here")),
         .object(Element(name: "test_something"))
      ]

      let stringResult = string.findFirst(elementNamed: "something", recursive: true)
      let cannotFind = source.findFirst(elementNamed: "not_existent", recursive: true)
      let testResult = source.findFirst(elementNamed: "test", recursive: true)
      let whateverResult = source.findFirst(elementNamed: "whatever", recursive: true)

      XCTAssertNil(stringResult)
      XCTAssertNil(cannotFind)
      XCTAssertNotNil(testResult)
      XCTAssertNotNil(whateverResult)
      XCTAssertEqual(testResult?.content, ["value"])
      // Make sure we only recurse lazily. We don't want to go into the deepest abyss if we can stay in shallower waters.
      XCTAssertEqual(whateverResult?.content, ["not so deep"])
   }

   func testFindingLastObjectRecursive() {
      let string: [Element.Content] = [.string("testStr")]
      let source: [Element.Content] = [
         .object(Element(name: "test_something",
                         objects: Element(name: "test", content: "value"))),
         .object(Element(name: "test_it")),
         .object(Element(name: "is", objects:
            Element(name: "add", objects:
               Element(name: "some", objects:
                  Element(name: "deeper"),
                       Element(name: "levels", objects:
                        Element(name: "deeper"),
                               Element(name: "whatever", content: "deep down")
                  )
               ),
                    Element(name: "whatever", content: "not so deep"),
                    Element(name: "deeper")
            ),
                         Element(name: "deeper"))
         ),
         .object(Element(name: "here", objects: Element(name: "test"))),
         .object(Element(name: "test_something")),
         ]

      let stringResult = string.findLast(elementNamed: "something", recursive: true)
      let cannotFind = source.findLast(elementNamed: "not_existent", recursive: true)
      let testResult = source.findLast(elementNamed: "test", recursive: true)
      let whateverResult = source.findLast(elementNamed: "whatever", recursive: true)

      XCTAssertNil(stringResult)
      XCTAssertNil(cannotFind)
      XCTAssertNotNil(testResult)
      XCTAssertNotNil(whateverResult)
      XCTAssertTrue(testResult?.content.isEmpty ?? false)
      // Make sure we only recurse lazily. We don't want to go into the deepest abyss if we can stay in shallower waters.
      XCTAssertEqual(whateverResult?.content, ["not so deep"])
   }

   static var allTests = [
      ("testFindingObjectsShallow", testFindingObjectsShallow),
      ("testFindingFirstObjectShallow", testFindingFirstObjectShallow),
      ("testFindingLastObjectShallow", testFindingLastObjectShallow),
      ("testFindingObjectsRecursive", testFindingObjectsRecursive),
      ("testFindingFirstObjectRecursive", testFindingFirstObjectRecursive),
      ("testFindingLastObjectRecursive", testFindingLastObjectRecursive),
   ]
}

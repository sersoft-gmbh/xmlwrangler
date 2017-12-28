import XCTest
@testable import XMLWrangler

final class ElementContentTests: XCTestCase {
   func testExpressibleByStringLiteral() {
      let content1: Element.Content = "test"
      if case .string(let str) = content1 {
         XCTAssertEqual(str, "test")
      } else {
         XCTFail("Content is not string!")
      }
   }

   func testExpressibleByArrayLiteral() {
      let elem1 = Element(name: "a")
      let elem2 = Element(name: "b", attributes: ["key": "value"])
    
      let content1: Element.Content = [elem1, elem2]

      if case .objects(let objs) = content1 {
         XCTAssertEqual(objs, [elem1, elem2])
      } else {
         XCTFail("Content is not objects!")
      }
   }

   func testEqualityCheck() {
      let content1 = Element.Content.string("test1")
      let content2 = Element.Content.string("test1")
      let content3 = Element.Content.string("test2")

      let elem1 = Element(name: "test1")
      let elem2 = Element(name: "test2")

      let content4 = Element.Content.objects([elem1])
      let content5 = Element.Content.objects([elem1])
      let content6 = Element.Content.objects([elem2])

      XCTAssertEqual(content1, content2)
      XCTAssertEqual(content4, content5)
      XCTAssertNotEqual(content1, content3)
      XCTAssertNotEqual(content1, content6)
      XCTAssertNotEqual(content2, content3)
      XCTAssertNotEqual(content4, content6)
   }

   func testAppendingString() {
      var unconvertedContent = Element.Content.objects(["testObj"])
      var extendedContent = Element.Content.string("test")

      unconvertedContent.append(string: "_this")
      extendedContent.append(string: "_this")

      if case .objects(_) = unconvertedContent {} else {
         XCTFail("Content must not be changed!")
      }
      if case .string(let str) = extendedContent {
         XCTAssertEqual("test_this", str)
      } else {
         XCTFail("Content must not be changed!")
      }
   }

   func testAppendingObject() {
      let elem1 = Element(name: "test1")
      let elem2 = Element(name: "test2")
      var unconvertedContent = Element.Content.string("testStr")
      var extendedContent = Element.Content.objects([elem1])

      unconvertedContent.append(object: elem2)
      extendedContent.append(object: elem2)

      if case .string(_) = unconvertedContent {} else {
         XCTFail("Content must not be changed!")
      }
      if case .objects(let objs) = extendedContent {
         XCTAssertEqual(objs, [elem1, elem2])
      } else {
         XCTFail("Content must not be changed!")
      }
   }

   func testAppendingContentOfSequence() {
      let elem1 = Element(name: "test1")
      let elem2 = Element(name: "test2")
      let elem3 = Element(name: "test3")
      var unconvertedContent = Element.Content.string("testStr")
      var extendedContent = Element.Content.objects([elem1])

      unconvertedContent.append(contentsOf: [elem2, elem3])
      extendedContent.append(contentsOf: [elem2, elem3])

      if case .string(_) = unconvertedContent {} else {
         XCTFail("Content must not be changed!")
      }
      if case .objects(let objs) = extendedContent {
         XCTAssertEqual(objs, [elem1, elem2, elem3])
      } else {
         XCTFail("Content must not be changed!")
      }
   }

   func testAppendingObjects() {
      let elem1 = Element(name: "test1")
      let elem2 = Element(name: "test2")
      let elem3 = Element(name: "test3")
      var unconvertedContent = Element.Content.string("testStr")
      var extendedContent = Element.Content.objects([elem1])

      unconvertedContent.append(objects: elem2, elem3)
      extendedContent.append(objects: elem2, elem3)

      if case .string(_) = unconvertedContent {} else {
         XCTFail("Content must not be changed!")
      }
      if case .objects(let objs) = extendedContent {
         XCTAssertEqual(objs, [elem1, elem2, elem3])
      } else {
         XCTFail("Content must not be changed!")
      }
   }

   func testConverting() {
      let objectsContent = Element.Content.objects([Element(name: "test")])
      let doubleContent = Element.Content.string("4.2")
      let intContent = Element.Content.string("42")
      let versionContent = Element.Content.string("2.1.0")

      let convertedObjectsContent: Int? = objectsContent.converted()
      let convertedDoubleContent: Double? = doubleContent.converted()
      let convertedIntContent: Int? = intContent.converted()
      let convertedVersionContent: Version? = versionContent.converted()

      XCTAssertNil(convertedObjectsContent)
      XCTAssertNotNil(convertedDoubleContent)
      XCTAssertEqual(convertedDoubleContent, 4.2)
      XCTAssertNotNil(convertedIntContent)
      XCTAssertEqual(convertedIntContent, 42)
      XCTAssertNotNil(convertedVersionContent)
      XCTAssertEqual(convertedVersionContent, Version(major: 2, minor: 1, patch: 0))
   }
   
   func testFindingObjectsShallow() {
      let string: Element.Content = .string("testStr")
      let source: Element.Content = .objects([
         Element(name: "test"),
         Element(name: "test_something"),
         Element(name: "whatever"),
         Element(name: "test"),
         Element(name: "is"),
         Element(name: "here"),
         Element(name: "test_something"),
         ])
      
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
      let string: Element.Content = .string("testStr")
      let source: Element.Content = .objects([
         Element(name: "test", content: "value"),
         Element(name: "test_something"),
         Element(name: "whatever"),
         Element(name: "test"),
         Element(name: "is"),
         Element(name: "here"),
         Element(name: "test_something"),
         ])
      
      let stringResult = string.findFirst(elementNamed: "something")
      let cannotFind = source.findFirst(elementNamed: "not_existent")
      let testResult = source.findFirst(elementNamed: "test")
      let whateverResult = source.findFirst(elementNamed: "whatever")
      
      XCTAssertNil(stringResult)
      XCTAssertNil(cannotFind)
      XCTAssertNotNil(testResult)
      XCTAssertNotNil(whateverResult)
      XCTAssertEqual(testResult?.content ?? [], ["value"])
      XCTAssertTrue(whateverResult?.content.isEmpty ?? false)
   }
   
   func testFindingLastObjectShallow() {
      let string: Element.Content = .string("testStr")
      let source: Element.Content = .objects([
         Element(name: "test"),
         Element(name: "test_something"),
         Element(name: "whatever"),
         Element(name: "test", content: "value"),
         Element(name: "is"),
         Element(name: "here"),
         Element(name: "test_something"),
         ])
      
      let stringResult = string.findLast(elementNamed: "something")
      let cannotFind = source.findLast(elementNamed: "not_existent")
      let testResult = source.findLast(elementNamed: "test")
      let whateverResult = source.findLast(elementNamed: "whatever")
      
      XCTAssertNil(stringResult)
      XCTAssertNil(cannotFind)
      XCTAssertNotNil(testResult)
      XCTAssertNotNil(whateverResult)
      XCTAssertEqual(testResult?.content ?? [], ["value"])
      XCTAssertTrue(whateverResult?.content.isEmpty ?? false)
   }
   
   func testFindingObjectsRecursive() {
      let string: Element.Content = .string("testStr")
      let source: Element.Content = .objects([
         Element(name: "test_something", content: [
            Element(name: "test", content: "value"),
            ]),
         Element(name: "test_it"),
         Element(name: "is", content: [
            Element(name: "add", content: [
               Element(name: "some", content: [
                  Element(name: "deeper"),
                  Element(name: "levels", content: [
                     Element(name: "deeper"),
                     Element(name: "whatever")
                     ])
                  ]),
               Element(name: "test"),
               Element(name: "deeper"),
               ]),
            Element(name: "deeper"),
            ]),
         Element(name: "here"),
         Element(name: "test_something"),
         ])
      
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
      let string: Element.Content = .string("testStr")
      let source: Element.Content = .objects([
         Element(name: "test_something", content: [
            Element(name: "test", content: "value"),
            ]),
         Element(name: "test_it"),
         Element(name: "is", content: [
            Element(name: "add", content: [
               Element(name: "some", content: [
                  Element(name: "deeper"),
                  Element(name: "levels", content: [
                     Element(name: "deeper"),
                     Element(name: "whatever", content: "deep down")
                     ])
                  ]),
               Element(name: "test"),
               Element(name: "whatever", content: "not so deep"),
               Element(name: "deeper"),
               ]),
            Element(name: "deeper"),
            ]),
         Element(name: "here"),
         Element(name: "test_something"),
         ])
      
      let stringResult = string.findFirst(elementNamed: "something", recursive: true)
      let cannotFind = source.findFirst(elementNamed: "not_existent", recursive: true)
      let testResult = source.findFirst(elementNamed: "test", recursive: true)
      let whateverResult = source.findFirst(elementNamed: "whatever", recursive: true)
      
      XCTAssertNil(stringResult)
      XCTAssertNil(cannotFind)
      XCTAssertNotNil(testResult)
      XCTAssertNotNil(whateverResult)
      XCTAssertEqual(testResult?.content ?? [], ["value"])
      // Make sure we only recurse lazily. We don't want to go into the deepest abyss if we can stay in shallower waters.
      XCTAssertEqual(whateverResult?.content ?? [], ["not so deep"])
   }
   
   func testFindingLastObjectRecursive() {
      let string: Element.Content = .string("testStr")
      let source: Element.Content = .objects([
         Element(name: "test_something", content: [
            Element(name: "test", content: "value"),
            ]),
         Element(name: "test_it"),
         Element(name: "is", content: [
            Element(name: "add", content: [
               Element(name: "some", content: [
                  Element(name: "deeper"),
                  Element(name: "levels", content: [
                     Element(name: "deeper"),
                     Element(name: "whatever", content: "deep down")
                     ])
                  ]),
               Element(name: "whatever", content: "not so deep"),
               Element(name: "deeper"),
               ]),
            Element(name: "deeper"),
            ]),
         Element(name: "here", content: [
            Element(name: "test"),
            ]),
         Element(name: "test_something"),
         ])
      
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
      XCTAssertEqual(whateverResult?.content ?? [], ["not so deep"])
   }

   static var allTests = [
      ("testExpressibleByStringLiteral", testExpressibleByStringLiteral),
      ("testExpressibleByArrayLiteral", testExpressibleByArrayLiteral),
      ("testEqualityCheck", testEqualityCheck),
      ("testAppendingString", testAppendingString),
      ("testAppendingObject", testAppendingObject),
      ("testAppendingObjects", testAppendingObjects),
      ("testConverting", testConverting),
      ("testFindingObjectsShallow", testFindingObjectsShallow),
      ("testFindingFirstObjectShallow", testFindingFirstObjectShallow),
      ("testFindingLastObjectShallow", testFindingLastObjectShallow),
      ("testFindingObjectsRecursive", testFindingObjectsRecursive),
      ("testFindingFirstObjectRecursive", testFindingFirstObjectRecursive),
      ("testFindingLastObjectRecursive", testFindingLastObjectRecursive),
   ]
}

import XCTest
@testable import XMLWrangler

fileprivate extension Element.Content {
   var _object: Element! {
      get { return object }
      set { self = .object(newValue) }
   }
}

final class Element_MutationTests: XCTestCase {
   private var sut: Element!

   override func setUp() {
      super.setUp()
      sut = Element(name: "Root",
                    objects: [
                     Element(name: "Child1", attributes: ["some": "value"], objects: Element(name: "Child1.1")),
                     Element(name: "Child2", objects: Element(name: "Child2.1", attributes: ["other": "value"])),
                     ])
   }

   override func tearDown() {
      sut = nil

      super.tearDown()
   }

   func testMutatingAccessToElementAtInvalidPathThrows() {
      XCTAssertThrowsError(try sut.withMutatingAccess(toElementAt: "Child1", "InexistentChild", do: { _ in XCTFail("Should not be called!") })) {
         XCTAssert($0, is: .missingChild(element: sut.content[0]._object, childElementName: "InexistentChild"))
      }
   }

   func testMutatingAccessToElementAtPath() throws {
      var expectedResult: Element = sut
      expectedResult.content[0]._object.content[0]._object.append(object: Element(name: "Test"))
      try sut.withMutatingAccess(toElementAt: ["Child1", "Child1.1"], do: { $0.append(object: Element(name: "Test")) })
      XCTAssertEqual(sut, expectedResult)
   }

   func testMutatingAccessToElementAtVariadicPath() throws {
      var expectedResult: Element = sut
      expectedResult.content[0]._object.content[0]._object.append(object: Element(name: "Test"))
      try sut.withMutatingAccess(toElementAt: "Child1", "Child1.1", do: { $0.append(object: Element(name: "Test")) })
      XCTAssertEqual(sut, expectedResult)
   }

   func testReplacingElementAtPath() throws {
      var expectedResult: Element = sut
      expectedResult.content[0]._object.content[0]._object = Element(name: "Test")
      try sut.replace(elementAtPath: ["Child1", "Child1.1"], with: Element(name: "Test"))
      XCTAssertEqual(sut, expectedResult)
   }

   func testReplacingElementAtVariadicPath() throws {
      var expectedResult: Element = sut
      expectedResult.content[0]._object.content[0]._object = Element(name: "Test")
      try sut.replace(elementAtPath: "Child1", "Child1.1", with: Element(name: "Test"))
      XCTAssertEqual(sut, expectedResult)
   }
}

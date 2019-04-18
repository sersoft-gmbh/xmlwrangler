import XCTest
@testable import XMLWrangler

@available(*, deprecated, message: "Tests deprecated API")
final class ElementContent_DeprecatedTests: XCTestCase {
   private struct StringConvertible: LosslessStringConvertible, Equatable {
      let description: String
      init(_ description: String) { self.description = description }
   }

   func testElementContentConverted() {
      let content = Element.Content.string("Test")
      XCTAssertEqual(content.converted(), StringConvertible("Test"))
   }

   func testElementContentAppend() {
      let testElement = Element(name: "Unused")
      var objContent = Element.Content.object(testElement)
      var strContent = Element.Content.string("Test")
      objContent.append(string: "Something")
      strContent.append(string: "Again")
      XCTAssertEqual(strContent, .string("TestAgain"))
      XCTAssertEqual(objContent, .object(testElement))
   }

   func testElementRemoveAtPath() throws {
      var testElement = Element(
         name: "Root",
         objects: [
            Element(name: "Child1", attributes: ["some": "value"], objects: Element(name: "Child1.1")),
            Element(name: "Child2", objects: Element(name: "Child2.1", attributes: ["other": "value"])),
         ])
      var expectedResult = testElement
      try expectedResult.replace(elementAt: ["Child1", "Child1.1"], with: Element(name: "NEW"))
      try testElement.replace(elementAtPath: ["Child1", "Child1.1"], with: Element(name: "NEW"))
      XCTAssertEqual(expectedResult, testElement)
   }

   func testElementRemoveAtVariadicPath() throws {
      var testElement = Element(
         name: "Root",
         objects: [
            Element(name: "Child1", attributes: ["some": "value"], objects: Element(name: "Child1.1")),
            Element(name: "Child2", objects: Element(name: "Child2.1", attributes: ["other": "value"])),
         ])
      var expectedResult = testElement
      try expectedResult.replace(elementAt: "Child1", "Child1.1", with: Element(name: "NEW"))
      try testElement.replace(elementAtPath: "Child1", "Child1.1", with: Element(name: "NEW"))
      XCTAssertEqual(expectedResult, testElement)
   }
}

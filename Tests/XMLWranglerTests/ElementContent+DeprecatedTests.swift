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
}

import XCTest
@testable import XMLWrangler

class ParserTests: XCTestCase {
   
   private let testRoot: Element = {
      var root = Element(name: "root", attributes: ["some": "key"], content: .objects([]))
      root.content.append(object: "first")
      root.content.append(object: Element(name: "second", content: "something"))
      root.content.append(object: Element(name: "third", content: [
         "third_one",
         Element(name: "third_two", attributes: ["third_some": "value"]),
         Element(name: "third_three", attributes: ["third_some": "value"], content: "test this right")
         ]))
      return root
   }()
   
   private let xml1 = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root some=\"key\"><first/><second>something</second><third><third_one/><third_two third_some=\"value\"/><third_three third_some=\"value\">test this right</third_three></third></root>"
   private let xml2 = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<root some=\"key\">\n<first/>\n<second>something</second>\n<third>\n<third_one/>\n<third_two third_some=\"value\"/>\n<third_three third_some=\"value\">test this right</third_three>\n</third>\n</root>\n"
   private let xml3 = "<?xml version='1.0' encoding='UTF-8'?><root some='key'><first/><second>something</second><third><third_one/><third_two third_some='value'/><third_three third_some='value'>test this right</third_three></third></root>"
   private let xml4 = "<?xml version='1.0' encoding='UTF-8'?>\n<root some='key'>\n<first/>\n<second>something</second>\n<third>\n<third_one/>\n<third_two third_some='value'/>\n<third_three third_some='value'>test this right</third_three>\n</third>\n</root>\n"

   
   func testParserCreationFromString() {
      let simpleXML = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root><first/><second>test</second></root>"
      let parser = Parser(string: simpleXML)
      
      XCTAssertNotNil(parser)
   }
   
   func testSuccessfulParsing() {
      guard let parser1 = Parser(string: xml1) else { XCTFail("Parser is nil!"); return }
      guard let parser2 = Parser(string: xml2) else { XCTFail("Parser is nil!"); return }
      guard let parser3 = Parser(string: xml3) else { XCTFail("Parser is nil!"); return }
      guard let parser4 = Parser(string: xml4) else { XCTFail("Parser is nil!"); return }
      
      XCTAssertEqual(try parser1.parse(), testRoot)
      XCTAssertEqual(try parser2.parse(), testRoot)
      XCTAssertEqual(try parser3.parse(), testRoot)
      XCTAssertEqual(try parser4.parse(), testRoot)
   }
   
   static var allTests = [
      ("testParserCreationFromString", testParserCreationFromString),
      ("testSuccessfulParsing", testSuccessfulParsing),
      ]
}

import XCTest
@testable import XMLWrangler

class SerializationTests: XCTestCase {

   func testEscapeableContentEquality() {
      let content1: EscapableContent = .attribute(quotes: .single)
      let content2: EscapableContent = .attribute(quotes: .single)
      let content3: EscapableContent = .attribute(quotes: .double)
      let content4: EscapableContent = .comment
      let content5: EscapableContent = .comment

      XCTAssertEqual(content1, content2)
      XCTAssertEqual(content4, content5)
      XCTAssertNotEqual(content2, content3)
      XCTAssertNotEqual(content1, content3)
      XCTAssertNotEqual(content3, content5)
   }

   func testEscapingStrings() {
      let testString = "\"some_kind_of' < string & others > or this"

      let expectedAttributeSingle = "\"some_kind_of&apos; &lt; string &amp; others > or this"
      let expectedAttributeDouble = "&quot;some_kind_of' &lt; string &amp; others > or this"
      let expectedText = "\"some_kind_of' &lt; string &amp; others > or this"
      let expectedCDATA = testString
      let expectedComment = testString
      let expectedProcessingInstruction = testString

      var attributeSingle = testString
      var attributeDouble = testString
      var text = testString
      var cdata = testString
      var comment = testString
      var processingInstructions = testString

      attributeSingle.escape(content: .attribute(quotes: .single))
      attributeDouble.escape(content: .attribute(quotes: .double))
      text.escape(content: .text)
      cdata.escape(content: .cdata)
      comment.escape(content: .comment)
      processingInstructions.escape(content: .processingInstruction)

      // Non-Mutating
      XCTAssertEqual(testString.escaped(content: .attribute(quotes: .single)), expectedAttributeSingle)
      XCTAssertEqual(testString.escaped(content: .attribute(quotes: .double)), expectedAttributeDouble)
      XCTAssertEqual(testString.escaped(content: .text), expectedText)
      XCTAssertEqual(testString.escaped(content: .cdata), expectedCDATA)
      XCTAssertEqual(testString.escaped(content: .comment), expectedComment)
      XCTAssertEqual(testString.escaped(content: .processingInstruction), expectedProcessingInstruction)
      // Mutating
      XCTAssertEqual(attributeSingle, expectedAttributeSingle)
      XCTAssertEqual(attributeDouble, expectedAttributeDouble)
      XCTAssertEqual(text, expectedText)
      XCTAssertEqual(cdata, expectedCDATA)
      XCTAssertEqual(comment, expectedComment)
      XCTAssertEqual(processingInstructions, expectedProcessingInstruction)
   }

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

   func testXMLSerialization() {
      let str1 = String(xml: testRoot)
      let expected1 = "<root some=\"key\"><first/><second>something</second><third><third_one/><third_two third_some=\"value\"/><third_three third_some=\"value\">test this right</third_three></third></root>"

      let str2 = String(xml: testRoot, options: [.pretty])
      let expected2 = "<root some=\"key\">\n<first/>\n<second>something</second>\n<third>\n<third_one/>\n<third_two third_some=\"value\"/>\n<third_three third_some=\"value\">test this right</third_three>\n</third>\n</root>\n"

      let str3 = String(xml: testRoot, options: [.singleQuoteAttributes])
      let expected3 = "<root some='key'><first/><second>something</second><third><third_one/><third_two third_some='value'/><third_three third_some='value'>test this right</third_three></third></root>"

      let str4 = String(xml: testRoot, options: [.pretty, .singleQuoteAttributes])
      let expected4 = "<root some='key'>\n<first/>\n<second>something</second>\n<third>\n<third_one/>\n<third_two third_some='value'/>\n<third_three third_some='value'>test this right</third_three>\n</third>\n</root>\n"

      XCTAssertEqual(str1, expected1)
      XCTAssertEqual(str2, expected2)
      XCTAssertEqual(str3, expected3)
      XCTAssertEqual(str4, expected4)
   }

   func testXMLDocumentSerialization() {
      let str1 = String(xmlDocumentRoot: testRoot, version: Version(major: 1), encoding: .utf8)
      let expected1 = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root some=\"key\"><first/><second>something</second><third><third_one/><third_two third_some=\"value\"/><third_three third_some=\"value\">test this right</third_three></third></root>"

      let str2 = String(xmlDocumentRoot: testRoot, version: Version(major: 1), encoding: .utf8, options: [.pretty])
      let expected2 = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<root some=\"key\">\n<first/>\n<second>something</second>\n<third>\n<third_one/>\n<third_two third_some=\"value\"/>\n<third_three third_some=\"value\">test this right</third_three>\n</third>\n</root>\n"

      let str3 = String(xmlDocumentRoot: testRoot, version: Version(major: 1), encoding: .utf8, options: [.singleQuoteAttributes])
      let expected3 = "<?xml version='1.0' encoding='UTF-8'?><root some='key'><first/><second>something</second><third><third_one/><third_two third_some='value'/><third_three third_some='value'>test this right</third_three></third></root>"

      let str4 = String(xmlDocumentRoot: testRoot, version: Version(major: 1), encoding: .utf8, options: [.pretty, .singleQuoteAttributes])
      let expected4 = "<?xml version='1.0' encoding='UTF-8'?>\n<root some='key'>\n<first/>\n<second>something</second>\n<third>\n<third_one/>\n<third_two third_some='value'/>\n<third_three third_some='value'>test this right</third_three>\n</third>\n</root>\n"

      XCTAssertEqual(str1, expected1)
      XCTAssertEqual(str2, expected2)
      XCTAssertEqual(str3, expected3)
      XCTAssertEqual(str4, expected4)
   }

   static var allTests = [
      ("testEscapeableContentEquality", testEscapeableContentEquality),
      ("testEscapingStrings", testEscapingStrings),
      ("testXMLSerialization", testXMLSerialization),
      ("testXMLDocumentSerialization", testXMLDocumentSerialization),
   ]
}

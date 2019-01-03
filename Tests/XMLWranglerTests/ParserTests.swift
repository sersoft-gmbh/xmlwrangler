import XCTest
@testable import XMLWrangler

final class ParserTests: XCTestCase {

   private let testRoot: Element = {
      var root = Element(name: "root", attributes: ["some": "key"])
      root.append(object: "first")
      root.append(object: Element(name: "second", content: "something"))
      root.append(object: Element(name: "third", objects: [
         "third_one",
         Element(name: "third_two", attributes: ["third_some": "value"]),
         Element(name: "third_three", attributes: ["third_some": "value"], content: "test this right")
         ]))
      root.append(object: Element(name: "fourth", content: "Some <CDATA> value"))
      return root
   }()

   private let xml1 = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root some=\"key\"><first/><second>something</second><third><third_one/><third_two third_some=\"value\"/><third_three third_some=\"value\">test this right</third_three></third><fourth><![CDATA[Some <CDATA> value]]></fourth></root>"
   private let xml2 = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<root some=\"key\">\n<first/>\n<second>something</second>\n<third>\n<third_one/>\n<third_two third_some=\"value\"/>\n<third_three third_some=\"value\">test this right</third_three>\n</third>\n<fourth>\n<![CDATA[Some <CDATA> value]]>\n</fourth>\n</root>\n"
   private let xml3 = "<?xml version='1.0' encoding='UTF-8'?><root some='key'><first/><second>something</second><third><third_one/><third_two third_some='value'/><third_three third_some='value'>test this right</third_three></third><fourth><![CDATA[Some <CDATA> value]]></fourth></root>"
   private let xml4 = "<?xml version='1.0' encoding='UTF-8'?>\n<root some='key'>\n<first/>\n<second>something</second>\n<third>\n<third_one/>\n<third_two third_some='value'/>\n<third_three third_some='value'>test this right</third_three>\n</third>\n<fourth>\n<![CDATA[Some <CDATA> value]]>\n</fourth>\n</root>\n"


   func testParsingError() {
      let invalidXML = "Totally not XML"
      let parser = Parser(string: invalidXML)

      XCTAssertThrowsError(try parser.parse()) {
         switch $0 {
         case is Parser.UnknownError:
            XCTAssertTrue($0 is Parser.UnknownError)
         case let nsError as NSError:
            XCTAssertEqual(nsError.domain, XMLParser.errorDomain)
         }
      }
   }

   func testSuccessfulParsing() {
      let parser1 = Parser(string: xml1)
      let parser2 = Parser(string: xml2)
      let parser3 = Parser(string: xml3)
      let parser4 = Parser(string: xml4)

      XCTAssertEqual(try parser1.parse(), testRoot)
      XCTAssertEqual(try parser2.parse(), testRoot)
      XCTAssertEqual(try parser3.parse(), testRoot)
      XCTAssertEqual(try parser4.parse(), testRoot)
   }

   func testRepetitiveParsing() throws {
      let parser = Parser(string: xml1)
      let start1 = DispatchTime.now().uptimeNanoseconds
      let run1 = try parser.parse()
      let duration1 = DispatchTime.now().uptimeNanoseconds - start1
      let start2 = DispatchTime.now().uptimeNanoseconds
      let run2 = try parser.parse()
      let duration2 = DispatchTime.now().uptimeNanoseconds - start2

      XCTAssertEqual(run1, run2)
      // The second run's gotta be much faster since we return the previously parsed object directly.
      XCTAssertLessThan(duration2, duration1)
   }

   func testMixedContentParsing() {
      let mixedContentXML = """
                            <?xml version="1.0" encoding="UTF-8"?>
                            <root>
                            Some text is here to check.
                            Which even contains newlines.
                            <child>I'm not of much relevance</child>
                            <child/>
                            Again we have some more text here.
                            Let's see how this will end.
                            <other/>
                            </root>
                            """
      let expectedElement = Element(name: "root", content: [
         .string("Some text is here to check.\nWhich even contains newlines."),
         .object(Element(name: "child", content: "I'm not of much relevance")),
         .object(Element(name: "child")),
         .string("Again we have some more text here.\nLet's see how this will end."),
         .object(Element(name: "other"))
         ])
      let parser = Parser(string: mixedContentXML)
      XCTAssertEqual(try parser.parse(), expectedElement)
   }
}

import XCTest
@testable import XMLWrangler

final class SerializationTests: XCTestCase {
    func testDocumentEncodingDescription() {
        XCTAssertEqual(String(describing: XWElement.DocumentEncoding.ascii), "ASCII")
        XCTAssertEqual(String(describing: XWElement.DocumentEncoding.utf8), "UTF-8")
        XCTAssertEqual(String(describing: XWElement.DocumentEncoding.utf16), "UTF-16")
    }

    func testEscapableContentQuotesDescription() {
        XCTAssertEqual(String(describing: XWElement.EscapableContent.Quotes.single), "Single quotes")
        XCTAssertEqual(String(describing: XWElement.EscapableContent.Quotes.double), "Double quotes")
    }

    func testEscapableContentDescription() {
        XCTAssertEqual(String(describing: XWElement.EscapableContent.attribute(quotes: .single)), "Attribute enclosed in single quotes")
        XCTAssertEqual(String(describing: XWElement.EscapableContent.attribute(quotes: .double)), "Attribute enclosed in double quotes")
        XCTAssertEqual(String(describing: XWElement.EscapableContent.text), "Text")
        XCTAssertEqual(String(describing: XWElement.EscapableContent.cdata), "CDATA")
        XCTAssertEqual(String(describing: XWElement.EscapableContent.comment), "Comment")
        XCTAssertEqual(String(describing: XWElement.EscapableContent.processingInstruction), "Processing instruction")
    }

    func testEscapingStrings() {
        func escape(_ content: XWElement.EscapableContent, in string: some StringProtocol) -> String {
            content.escape(string)
        }

        let testString = "\"some_kind_of' < string & others > or this"

        XCTAssertEqual(escape(.attribute(quotes: .single), in: testString), "\"some_kind_of&apos; &lt; string &amp; others > or this")
        XCTAssertEqual(escape(.attribute(quotes: .double), in: testString), "&quot;some_kind_of' &lt; string &amp; others > or this")
        XCTAssertEqual(escape(.text, in: testString), "\"some_kind_of' &lt; string &amp; others > or this")
        XCTAssertEqual(escape(.cdata, in: testString), testString)
        XCTAssertEqual(escape(.comment, in: testString), testString)
        XCTAssertEqual(escape(.processingInstruction, in: testString), testString)
    }

    private let testRoot = XWElement(name: "root", attributes: ["some": "key"]) {
        XWElement(name: "first")
        XWElement(name: "second", content: "something")
        XWElement(name: "third", elements: [
            XWElement(name: "third_one"),
            XWElement(name: "third_two", attributes: ["third_some": "value"]),
            XWElement(name: "third_three", attributes: ["third_some": "value"], content: "test this right"),
        ])
    }

    private let mixedContentRoot = XWElement(name: "root") {
        "Some text is here to check."
        "Which even contains newlines."
        XWElement(name: "child", content: "I'm not of much relevance")
        XWElement(name: "child")
        "Again we have some more text here."
        "Let's see how this will end."
        XWElement(name: "other")
    }

    func testXMLSerialization() {
        let str1 = testRoot.serialize()
        let expected1 = #"<root some="key"><first/><second>something</second><third><third_one/><third_two third_some="value"/><third_three third_some="value">test this right</third_three></third></root>"#

        let str2 = testRoot.serialize(with: [.pretty])
        let expected2 = #"""
        <root some="key">
        <first/>
        <second>something</second>
        <third>
        <third_one/>
        <third_two third_some="value"/>
        <third_three third_some="value">test this right</third_three>
        </third>
        </root>
        """#

        let str3 = testRoot.serialize(with: [.singleQuoteAttributes])
        let expected3 = "<root some='key'><first/><second>something</second><third><third_one/><third_two third_some='value'/><third_three third_some='value'>test this right</third_three></third></root>"

        let str4 = testRoot.serialize(with: [.pretty, .singleQuoteAttributes])
        let expected4 = "<root some='key'>\n<first/>\n<second>something</second>\n<third>\n<third_one/>\n<third_two third_some='value'/>\n<third_three third_some='value'>test this right</third_three>\n</third>\n</root>"

        let str5 = testRoot.serialize(with: [.pretty, .explicitClosingTag])
        let expected5 = #"""
        <root some="key">
        <first></first>
        <second>something</second>
        <third>
        <third_one></third_one>
        <third_two third_some="value"></third_two>
        <third_three third_some="value">test this right</third_three>
        </third>
        </root>
        """#

        XCTAssertEqual(str1, expected1)
        XCTAssertEqual(str2, expected2)
        XCTAssertEqual(str3, expected3)
        XCTAssertEqual(str4, expected4)
        XCTAssertEqual(str5, expected5)
    }

    func testXMLDocumentSerialization() {
        let str1 = testRoot.serializeAsDocument(at: .init(major: 1), in: .utf8)
        let expected1 = #"<?xml version="1.0" encoding="UTF-8"?><root some="key"><first/><second>something</second><third><third_one/><third_two third_some="value"/><third_three third_some="value">test this right</third_three></third></root>"#

        let str2 = testRoot.serializeAsDocument(at: .init(major: 1), in: .utf8, with: [.pretty])
        let expected2 = #"""
        <?xml version="1.0" encoding="UTF-8"?>
        <root some="key">
        <first/>
        <second>something</second>
        <third>
        <third_one/>
        <third_two third_some="value"/>
        <third_three third_some="value">test this right</third_three>
        </third>
        </root>
        """#

        let str3 = testRoot.serializeAsDocument(at: .init(major: 1), in: .utf8, with: [.singleQuoteAttributes])
        let expected3 = "<?xml version='1.0' encoding='UTF-8'?><root some='key'><first/><second>something</second><third><third_one/><third_two third_some='value'/><third_three third_some='value'>test this right</third_three></third></root>"

        let str4 = testRoot.serializeAsDocument(at: .init(major: 1), in: .utf8, with: [.pretty, .singleQuoteAttributes])
        let expected4 = "<?xml version='1.0' encoding='UTF-8'?>\n<root some='key'>\n<first/>\n<second>something</second>\n<third>\n<third_one/>\n<third_two third_some='value'/>\n<third_three third_some='value'>test this right</third_three>\n</third>\n</root>"

        let str5 = testRoot.serializeAsDocument(at: .init(major: 1, minor: 2), in: .utf16)
        let expected5 = #"<?xml version="1.2" encoding="UTF-16"?><root some="key"><first/><second>something</second><third><third_one/><third_two third_some="value"/><third_three third_some="value">test this right</third_three></third></root>"#

        let str6 = testRoot.serializeAsDocument(at: .init(major: 2), in: .ascii)
        let expected6 = #"<?xml version="2.0" encoding="ASCII"?><root some="key"><first/><second>something</second><third><third_one/><third_two third_some="value"/><third_three third_some="value">test this right</third_three></third></root>"#

        XCTAssertEqual(str1, expected1)
        XCTAssertEqual(str2, expected2)
        XCTAssertEqual(str3, expected3)
        XCTAssertEqual(str4, expected4)
        XCTAssertEqual(str5, expected5)
        XCTAssertEqual(str6, expected6)
    }

    func testMixedContentSerialization() {
        let str1 = mixedContentRoot.serialize()
        let expected1 = "<root>Some text is here to check.\nWhich even contains newlines.<child>I'm not of much relevance</child><child/>Again we have some more text here.\nLet's see how this will end.<other/></root>"

        let str2 = mixedContentRoot.serialize(with: [.pretty])
        let expected2 = "<root>\nSome text is here to check.\nWhich even contains newlines.\n<child>I'm not of much relevance</child>\n<child/>\nAgain we have some more text here.\nLet's see how this will end.\n<other/>\n</root>"

        let str3 = mixedContentRoot.serialize(with: [.singleQuoteAttributes])
        let expected3 = "<root>Some text is here to check.\nWhich even contains newlines.<child>I'm not of much relevance</child><child/>Again we have some more text here.\nLet's see how this will end.<other/></root>"

        let str4 = mixedContentRoot.serialize(with: [.pretty, .singleQuoteAttributes])
        let expected4 = "<root>\nSome text is here to check.\nWhich even contains newlines.\n<child>I'm not of much relevance</child>\n<child/>\nAgain we have some more text here.\nLet's see how this will end.\n<other/>\n</root>"

        XCTAssertEqual(str1, expected1)
        XCTAssertEqual(str2, expected2)
        XCTAssertEqual(str3, expected3)
        XCTAssertEqual(str4, expected4)
    }

    private struct Convertible: XMLElementConvertible {
        let xml: XWElement
    }

    func testConvertibleSerialization() {
        XCTAssertEqual(Convertible(xml: mixedContentRoot).serializeAsXML(), mixedContentRoot.serialize())
        XCTAssertEqual(Convertible(xml: testRoot).serializeAsXMLDocument(), testRoot.serializeAsDocument())
    }
}

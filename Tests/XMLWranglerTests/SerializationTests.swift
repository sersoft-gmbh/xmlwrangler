import Testing
@testable import XMLWrangler

@Suite
struct SerializationTests {
    @Test
    func documentVersionDescription() {
        #expect(String(describing: XWElement.DocumentVersion(major: 1)) == "1.0")
        #expect(String(describing: XWElement.DocumentVersion(major: 2, minor: 3)) == "2.3")
    }

    @Test
    func documentVersionComparison() {
        #expect(XWElement.DocumentVersion(major: 1) < XWElement.DocumentVersion(major: 1, minor: 2))
    }

    @Test
    func documentEncodingDescription() {
        #expect(String(describing: XWElement.DocumentEncoding.ascii) == "ASCII")
        #expect(String(describing: XWElement.DocumentEncoding.utf8) == "UTF-8")
        #expect(String(describing: XWElement.DocumentEncoding.utf16) == "UTF-16")
    }

    @Test
    func escapableContentQuotesDescription() {
        #expect(String(describing: XWElement.EscapableContent.Quotes.single) == "Single quotes")
        #expect(String(describing: XWElement.EscapableContent.Quotes.double) == "Double quotes")
    }

    @Test
    func escapableContentDescription() {
        #expect(String(describing: XWElement.EscapableContent.attribute(quotes: .single)) == "Attribute enclosed in single quotes")
        #expect(String(describing: XWElement.EscapableContent.attribute(quotes: .double)) == "Attribute enclosed in double quotes")
        #expect(String(describing: XWElement.EscapableContent.text) == "Text")
        #expect(String(describing: XWElement.EscapableContent.cdata) == "CDATA")
        #expect(String(describing: XWElement.EscapableContent.comment) == "Comment")
        #expect(String(describing: XWElement.EscapableContent.processingInstruction) == "Processing instruction")
    }

    @Test
    func escapingStrings() {
        func escape(_ content: XWElement.EscapableContent, in string: some StringProtocol) -> String {
            content.escape(string)
        }

        let testString = "\"some_kind_of' < string & others > or this"

        #expect(escape(.attribute(quotes: .single), in: testString) == "\"some_kind_of&apos; &lt; string &amp; others > or this")
        #expect(escape(.attribute(quotes: .double), in: testString) == "&quot;some_kind_of' &lt; string &amp; others > or this")
        #expect(escape(.text, in: testString) == "\"some_kind_of' &lt; string &amp; others > or this")
        #expect(escape(.cdata, in: testString) == testString)
        #expect(escape(.comment, in: testString) == testString)
        #expect(escape(.processingInstruction, in: testString) == testString)
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

    @Test
    func xmlSerialization() {
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

        #expect(str1 == expected1)
        #expect(str2 == expected2)
        #expect(str3 == expected3)
        #expect(str4 == expected4)
        #expect(str5 == expected5)
    }

    @Test
    func xmlDocumentSerialization() {
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

        #expect(str1 == expected1)
        #expect(str2 == expected2)
        #expect(str3 == expected3)
        #expect(str4 == expected4)
        #expect(str5 == expected5)
        #expect(str6 == expected6)
    }

    @Test
    func mixedContentSerialization() {
        let str1 = mixedContentRoot.serialize()
        let expected1 = "<root>Some text is here to check.\nWhich even contains newlines.<child>I'm not of much relevance</child><child/>Again we have some more text here.\nLet's see how this will end.<other/></root>"

        let str2 = mixedContentRoot.serialize(with: [.pretty])
        let expected2 = "<root>\nSome text is here to check.\nWhich even contains newlines.\n<child>I'm not of much relevance</child>\n<child/>\nAgain we have some more text here.\nLet's see how this will end.\n<other/>\n</root>"

        let str3 = mixedContentRoot.serialize(with: [.singleQuoteAttributes])
        let expected3 = "<root>Some text is here to check.\nWhich even contains newlines.<child>I'm not of much relevance</child><child/>Again we have some more text here.\nLet's see how this will end.<other/></root>"

        let str4 = mixedContentRoot.serialize(with: [.pretty, .singleQuoteAttributes])
        let expected4 = "<root>\nSome text is here to check.\nWhich even contains newlines.\n<child>I'm not of much relevance</child>\n<child/>\nAgain we have some more text here.\nLet's see how this will end.\n<other/>\n</root>"

        #expect(str1 == expected1)
        #expect(str2 == expected2)
        #expect(str3 == expected3)
        #expect(str4 == expected4)
    }

    private struct Convertible: XMLElementConvertible {
        let xml: XWElement
    }

    @Test
    func convertibleSerialization() {
        #expect(Convertible(xml: mixedContentRoot).serializeAsXML() == mixedContentRoot.serialize())
        #expect(Convertible(xml: testRoot).serializeAsXMLDocument() == testRoot.serializeAsDocument())
    }
}

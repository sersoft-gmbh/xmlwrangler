import XCTest
#if canImport(FoundationXML)
import FoundationXML
#endif
@testable import XMLWrangler

final class ParsingTests: XCTestCase {
    private struct Expressible: ExpressibleByXMLElement {
        let element: XWElement

        init(xml: XWElement) throws {
            element = xml
        }
    }

    private let testRoot: XWElement = {
        var root = XWElement(name: "root", attributes: ["some": "key"])
        root.appendElement(XWElement(name: "first"))
        root.appendElement(XWElement(name: "second", content: "something"))
        root.appendElement(XWElement(name: "third", elements: [
            XWElement(name: "third_one"),
            XWElement(name: "third_two", attributes: ["third_some": "value"]),
            XWElement(name: "third_three", attributes: ["third_some": "value"], content: "test this right"),
        ]))
        root.appendElement(XMLElement(name: "fourth", content: "Some <CDATA> value"))
        return root
    }()

    private let xml1 = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root some=\"key\"><first/><second>something</second><third><third_one/><third_two third_some=\"value\"/><third_three third_some=\"value\">test this right</third_three></third><fourth><![CDATA[Some <CDATA> value]]></fourth></root>"
    private let xml2 = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<root some=\"key\">\n<first/>\n<second>something</second>\n<third>\n<third_one/>\n<third_two third_some=\"value\"/>\n<third_three third_some=\"value\">test this right</third_three>\n</third>\n<fourth>\n<![CDATA[Some <CDATA> value]]>\n</fourth>\n</root>\n"
    private let xml3 = "<?xml version='1.0' encoding='UTF-8'?><root some='key'><first/><second>something</second><third><third_one/><third_two third_some='value'/><third_three third_some='value'>test this right</third_three></third><fourth><![CDATA[Some <CDATA> value]]></fourth></root>"
    private let xml4 = "<?xml version='1.0' encoding='UTF-8'?>\n<root some='key'>\n<first/>\n<second>something</second>\n<third>\n<third_one/>\n<third_two third_some='value'/>\n<third_three third_some='value'>test this right</third_three>\n</third>\n<fourth>\n<![CDATA[Some <CDATA> value]]>\n</fourth>\n</root>\n"

    func testParsingErrors() {
        XCTAssertThrowsError(try XWElement.parse("<>Totally not valid XML<!>")) {
            switch $0 {
            case is XWElement.UnknownParsingError:
                XCTAssertTrue($0 is XWElement.UnknownParsingError)
            case is XWElement.MissingRootElementError:
                XCTAssertTrue($0 is XWElement.MissingRootElementError)
            case let nsError as NSError:
                XCTAssertEqual(nsError.domain, XMLParser.errorDomain)
            }
        }
    }

    func testSuccessfulParsing() {
        XCTAssertEqual(try XWElement.parse(xml1), testRoot)
        XCTAssertEqual(try XWElement.parse(xml2), testRoot)
        XCTAssertEqual(try XWElement.parse(xml3), testRoot)
        XCTAssertEqual(try XWElement.parse(xml4), testRoot)
    }

    func testMixedContentParsing() {
        let mixedContentXML = """
                            <?xml version="1.0" encoding="UTF-8"?>
                            <rootElement>
                            This is a text, here to check,
                            if newlines work correctly.
                            <childElement>I'm just sitting here</childElement>
                            <childElement/>
                            Again to check the works,
                            we add some newlines.
                            <otherElement/>
                            </rootElement>
                            """
        let expectedElement = XWElement(name: "rootElement", content: [
            .string("This is a text, here to check,\nif newlines work correctly."),
            .element(XWElement(name: "childElement", content: "I'm just sitting here")),
            .element(XWElement(name: "childElement")),
            .string("Again to check the works,\nwe add some newlines."),
            .element(XWElement(name: "otherElement")),
        ])
        XCTAssertEqual(try .parse(mixedContentXML), expectedElement)
    }

    func testParsingAndConverting() {
        XCTAssertEqual(try Expressible.parsedFromXML(Data(xml1.utf8)).element, testRoot)
        XCTAssertEqual(try Expressible.parsedFromXML(xml1).element, testRoot)
    }
}

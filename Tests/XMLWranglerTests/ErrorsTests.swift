import XCTest
@testable import XMLWrangler

final class ErrorsTests: XCTestCase {
    func testLookupErrorDescription() {
        let testElement = XWElement(name: "Root")
        let testKey = XWElement.Attributes.Key(rawValue: "TestKey")
        let testName = XWElement.Name(rawValue: "TestName")
        let testContent = "Test Content"
        let testType = Int32.self
        
        let missingAttribute = LookupError.missingAttribute(element: testElement, key: testKey)
        let cannotConvertAttribute = LookupError.cannotConvertAttribute(element: testElement, key: testKey, type: testType)
        let missingContent = LookupError.missingContent(element: testElement)
        let missingChild = LookupError.missingChild(element: testElement, childElementName: testName)
        let cannotConvertContent = LookupError.cannotConvertContent(element: testElement, content: testContent, type: testType)
        
        XCTAssertEqual(String(describing: missingAttribute),
                       "Element '\(testElement.name.rawValue)' has no attribute '\(testKey.rawValue)'!\nAttributes: \(testElement.attributes)")
        XCTAssertEqual(String(describing: cannotConvertAttribute),
                       "Could not convert attribute '\(testKey.rawValue)' of element '\(testElement.name.rawValue)' to \(testType)!\nAttribute value: \(testElement.attributes[testKey] ?? "nil")")
        XCTAssertEqual(String(describing: missingContent),
                       "Element '\(testElement.name.rawValue)' has no content!")
        XCTAssertEqual(String(describing: missingChild),
                       "Element '\(testElement.name.rawValue)' has no child named '\(testName.rawValue)'")
        XCTAssertEqual(String(describing: cannotConvertContent),
                       "Could not convert content of element '\(testElement.name.rawValue)' to \(testType)!\nContent: \(testContent)")
    }
    
    func testParserUnknownError() {
        XCTAssertEqual(String(describing: Parser.UnknownError()), "An unknown parsing error occurred!")
    }
    
    func testParserMissingRootElementError() {
        XCTAssertEqual(String(describing: Parser.MissingRootElementError()), "Parsing did not yield an element! Please check that the XML is valid!")
    }
}

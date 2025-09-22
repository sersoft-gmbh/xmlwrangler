import Testing
@testable import XMLWrangler

@Suite
struct ErrorsTests {
    @Test
    func lookupErrorDescription() {
        let testElement = XWElement(name: "Root")
        let testKey = XWElement.Attributes.Key(rawValue: "TestKey")
        let testAttributeContent: XWElement.Attributes.Content = "Test Attribute"
        let testName = XWElement.Name(rawValue: "TestName")
        let testStringContent = "Test Content"
        let testType = Int32.self

        let missingAttribute = XWElement.LookupError.missingAttribute(element: testElement, key: testKey)
        let cannotConvertAttribute = XWElement.LookupError.cannotConvertAttribute(element: testElement,
                                                                                  key: testKey,
                                                                                  content: testAttributeContent,
                                                                                  type: testType)
        let missingContent = XWElement.LookupError.missingStringContent(element: testElement)
        let missingChild = XWElement.LookupError.missingChild(element: testElement, childName: testName)
        let cannotConvertContent = XWElement.LookupError.cannotConvertStringContent(element: testElement,
                                                                                    stringContent: testStringContent,
                                                                                    type: testType)

        #expect(String(describing: missingAttribute)
                ==
                "Element '\(testElement.name.rawValue)' has no attribute '\(testKey.rawValue)'!\nAttributes: \(testElement.attributes)")
        #expect(String(describing: cannotConvertAttribute)
                ==
                "Could not convert attribute '\(testKey.rawValue)' of element '\(testElement.name.rawValue)' to \(testType)!\nAttribute content: \(testAttributeContent)")
        #expect(String(describing: missingContent)
                ==
                "Element '\(testElement.name.rawValue)' has no string content!")
        #expect(String(describing: missingChild)
                ==
                "Element '\(testElement.name.rawValue)' has no child named '\(testName.rawValue)'")
        #expect(String(describing: cannotConvertContent)
                ==
                "Could not convert content of element '\(testElement.name.rawValue)' to \(testType)!\nElement string content: \(testStringContent)")
    }

    @Test
    func parserUnknownParsingError() {
        #expect(String(describing: XWElement.UnknownParsingError()) == "An unknown parsing error occurred!")
    }

    @Test
    func parserMissingRootElementError() {
        #expect(String(describing: XWElement.MissingRootElementError())
                ==
                "Parsing did not yield an element! Please check that the XML is valid!")
    }
}

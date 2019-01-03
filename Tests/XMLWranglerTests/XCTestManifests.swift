import XCTest

extension ElementContentTests {
    static let __allTests = [
        ("testAppendingContentOfSequence", testAppendingContentOfSequence),
        ("testAppendingObject", testAppendingObject),
        ("testAppendingObjects", testAppendingObjects),
        ("testAppendingString", testAppendingString),
        ("testCompression", testCompression),
        ("testEqualityCheck", testEqualityCheck),
        ("testExpressibleByStringLiteral", testExpressibleByStringLiteral),
        ("testInternalHelpers", testInternalHelpers),
    ]
}

extension ElementContent_LookupTests {
    static let __allTests = [
        ("testFindingFirstObjectRecursive", testFindingFirstObjectRecursive),
        ("testFindingFirstObjectShallow", testFindingFirstObjectShallow),
        ("testFindingLastObjectRecursive", testFindingLastObjectRecursive),
        ("testFindingLastObjectShallow", testFindingLastObjectShallow),
        ("testFindingObjectsRecursive", testFindingObjectsRecursive),
        ("testFindingObjectsShallow", testFindingObjectsShallow),
    ]
}

extension ElementTests {
    static let __allTests = [
        ("testAppendingContentOfSequence", testAppendingContentOfSequence),
        ("testAppendingObject", testAppendingObject),
        ("testAppendingObjects", testAppendingObjects),
        ("testAppendingString", testAppendingString),
        ("testEqualityCheck", testEqualityCheck),
        ("testExpressibleByStringLiteral", testExpressibleByStringLiteral),
    ]
}

extension Element_LookupTests {
    static let __allTests = [
        ("testExistingAttributeConversion", testExistingAttributeConversion),
        ("testExistingAttributeConversionAtPath", testExistingAttributeConversionAtPath),
        ("testExistingAttributeConversionAtVariadicPath", testExistingAttributeConversionAtVariadicPath),
        ("testExistingAttributeLookup", testExistingAttributeLookup),
        ("testExistingAttributeLookupAtPath", testExistingAttributeLookupAtPath),
        ("testExistingAttributeLookupAtVariadicPath", testExistingAttributeLookupAtVariadicPath),
        ("testExistingElementLookupAtPath", testExistingElementLookupAtPath),
        ("testExistingElementLookupAtVariadicPath", testExistingElementLookupAtVariadicPath),
        ("testExistingElementsLookup", testExistingElementsLookup),
        ("testExistingElementsLookupAtPath", testExistingElementsLookupAtPath),
        ("testExistingElementsLookupAtVariadicPath", testExistingElementsLookupAtVariadicPath),
        ("testExistingStringContentConversion", testExistingStringContentConversion),
        ("testExistingStringContentConversionAtPath", testExistingStringContentConversionAtPath),
        ("testExistingStringContentConversionAtVariadicPath", testExistingStringContentConversionAtVariadicPath),
        ("testExistingStringContentLookup", testExistingStringContentLookup),
        ("testExistingStringContentLookupAtPath", testExistingStringContentLookupAtPath),
        ("testExistingStringContentLookupAtVariadicPath", testExistingStringContentLookupAtVariadicPath),
        ("testFailedExistingAttributeConversion", testFailedExistingAttributeConversion),
        ("testFailedExistingAttributeConversionAtPath", testFailedExistingAttributeConversionAtPath),
        ("testFailedExistingAttributeConversionAtVariadicPath", testFailedExistingAttributeConversionAtVariadicPath),
        ("testFailedExistingStringContentConversion", testFailedExistingStringContentConversion),
        ("testFailedExistingStringContentConversionAtPath", testFailedExistingStringContentConversionAtPath),
        ("testFailedExistingStringContentConversionAtVariadicPath", testFailedExistingStringContentConversionAtVariadicPath),
        ("testLosslessStringConvertibleAttributeConversion", testLosslessStringConvertibleAttributeConversion),
        ("testLosslessStringConvertibleAttributeConversionAtPath", testLosslessStringConvertibleAttributeConversionAtPath),
        ("testLosslessStringConvertibleAttributeConversionAtVariadicPath", testLosslessStringConvertibleAttributeConversionAtVariadicPath),
        ("testLosslessStringConvertibleStringContentConversion", testLosslessStringConvertibleStringContentConversion),
        ("testLosslessStringConvertibleStringContentConversionAtPath", testLosslessStringConvertibleStringContentConversionAtPath),
        ("testLosslessStringConvertibleStringContentConversionAtVariadicPath", testLosslessStringConvertibleStringContentConversionAtVariadicPath),
        ("testNonExistingAttributeConversion", testNonExistingAttributeConversion),
        ("testNonExistingAttributeConversionAtPath", testNonExistingAttributeConversionAtPath),
        ("testNonExistingAttributeConversionAtVariadicPath", testNonExistingAttributeConversionAtVariadicPath),
        ("testNonExistingAttributeLookup", testNonExistingAttributeLookup),
        ("testNonExistingAttributeLookupAtPath", testNonExistingAttributeLookupAtPath),
        ("testNonExistingAttributeLookupAtVariadicPath", testNonExistingAttributeLookupAtVariadicPath),
        ("testNonExistingElementLookupAtPath", testNonExistingElementLookupAtPath),
        ("testNonExistingElementLookupAtVariadicPath", testNonExistingElementLookupAtVariadicPath),
        ("testNonExistingElementsLookup", testNonExistingElementsLookup),
        ("testNonExistingElementsLookupAtPath", testNonExistingElementsLookupAtPath),
        ("testNonExistingElementsLookupAtVariadicPath", testNonExistingElementsLookupAtVariadicPath),
        ("testNonExistingStringContentConversion", testNonExistingStringContentConversion),
        ("testNonExistingStringContentConversionAtPath", testNonExistingStringContentConversionAtPath),
        ("testNonExistingStringContentConversionAtVariadicPath", testNonExistingStringContentConversionAtVariadicPath),
        ("testNonExistingStringContentLookup", testNonExistingStringContentLookup),
        ("testNonExistingStringContentLookupAtPath", testNonExistingStringContentLookupAtPath),
        ("testNonExistingStringContentLookupAtVariadicPath", testNonExistingStringContentLookupAtVariadicPath),
        ("testRawRepresentableAttributeConversion", testRawRepresentableAttributeConversion),
        ("testRawRepresentableAttributeConversionAtPath", testRawRepresentableAttributeConversionAtPath),
        ("testRawRepresentableAttributeConversionAtVariadicPath", testRawRepresentableAttributeConversionAtVariadicPath),
        ("testRawRepresentableStringContentConversion", testRawRepresentableStringContentConversion),
        ("testRawRepresentableStringContentConversionAtPath", testRawRepresentableStringContentConversionAtPath),
        ("testRawRepresentableStringContentConversionAtVariadicPath", testRawRepresentableStringContentConversionAtVariadicPath),
    ]
}

extension ParserTests {
    static let __allTests = [
        ("testMixedContentParsing", testMixedContentParsing),
        ("testParsingError", testParsingError),
        ("testRepetitiveParsing", testRepetitiveParsing),
        ("testSuccessfulParsing", testSuccessfulParsing),
    ]
}

extension SerializationTests {
    static let __allTests = [
        ("testEscapeableContentEquality", testEscapeableContentEquality),
        ("testEscapingStrings", testEscapingStrings),
        ("testMixedContentSerialization", testMixedContentSerialization),
        ("testXMLDocumentSerialization", testXMLDocumentSerialization),
        ("testXMLSerialization", testXMLSerialization),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ElementContentTests.__allTests),
        testCase(ElementContent_LookupTests.__allTests),
        testCase(ElementTests.__allTests),
        testCase(Element_LookupTests.__allTests),
        testCase(ParserTests.__allTests),
        testCase(SerializationTests.__allTests),
    ]
}
#endif

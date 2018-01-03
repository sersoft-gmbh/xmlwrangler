import XCTest
@testable import XMLWranglerTests

XCTMain([
    testCase(Element_LookupTests.allTests),
    testCase(ElementContent_LookupTests.allTests),
    testCase(ElementContentTests.allTests),
    testCase(ElementTests.allTests),
    testCase(ParserTests.allTests),
    testCase(SerializationTests.allTests),
])

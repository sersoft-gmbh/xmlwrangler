import XCTest
@testable import XMLWranglerTests

XCTMain([
    testCase(ElementTests.allTests),
    testCase(ElementContentTests.allTests),
])

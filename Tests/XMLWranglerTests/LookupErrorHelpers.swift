import XCTest
import XMLWrangler

// Only equatable for testing
extension LookupError: Equatable {
    public static func ==(lhs: LookupError, rhs: LookupError) -> Bool {
        switch (lhs, rhs) {
        case (.missingAttribute(let lhsElement, let lhsKey), .missingAttribute(let rhsElement, let rhsKey)):
            return lhsElement == rhsElement && lhsKey == rhsKey
        case (.cannotConvertAttribute(let lhsElement, let lhsKey, let lhsTargetType), .cannotConvertAttribute(let rhsElement, let rhsKey, let rhsTargetType)):
            return lhsElement == rhsElement && lhsKey == rhsKey && lhsTargetType == rhsTargetType
        case (.missingContent(let lhsElement), .missingContent(let rhsElement)):
            return lhsElement == rhsElement
        case (.missingChild(let lhsElement, let lhsChildElementName), .missingChild(let rhsElement, let rhsChildElementName)):
            return lhsElement == rhsElement && lhsChildElementName == rhsChildElementName
        case (.cannotConvertContent(let lhsElement, let lhsContent, let lhsTargetType), .cannotConvertContent(let rhsElement, let rhsContent, let rhsTargetType)):
            return lhsElement == rhsElement && lhsContent == rhsContent && lhsTargetType == rhsTargetType
        default:
            return false
        }
    }
}

func XCTAssert(_ error: Error, is expectedError: LookupError, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertTrue(error is LookupError, "\(error) is no \(LookupError.self)", file: file, line: line)
    XCTAssertEqual(error as? LookupError, expectedError, file: file, line: line)
}

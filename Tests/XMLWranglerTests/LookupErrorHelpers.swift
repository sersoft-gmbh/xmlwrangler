public import XMLWrangler

// Only equatable for testing
extension XWElement.LookupError: Equatable {
    private static func equalTypes(lhs: ConversionType, rhs: ConversionType) -> Bool {
#if compiler(>=6.3)
        lhs == rhs
#else
        String(describing: lhs) == String(describing: rhs)
#endif
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.missingChild(let lhsElement, let lhsChildElementName), .missingChild(let rhsElement, let rhsChildElementName)):
            lhsElement == rhsElement && lhsChildElementName == rhsChildElementName
        case (.missingAttribute(let lhsElement, let lhsKey), .missingAttribute(let rhsElement, let rhsKey)):
            lhsElement == rhsElement && lhsKey == rhsKey
        case (.cannotConvertAttribute(let lhsElement, let lhsKey, let lhsContent, let lhsTargetType),
              .cannotConvertAttribute(let rhsElement, let rhsKey, let rhsContent, let rhsTargetType)):
            lhsElement == rhsElement && lhsKey == rhsKey && lhsContent == rhsContent && equalTypes(lhs: lhsTargetType, rhs: rhsTargetType)
        case (.missingStringContent(let lhsElement), .missingStringContent(let rhsElement)):
            lhsElement == rhsElement
        case (.cannotConvertStringContent(let lhsElement, let lhsContent, let lhsTargetType),
              .cannotConvertStringContent(let rhsElement, let rhsContent, let rhsTargetType)):
            lhsElement == rhsElement && lhsContent == rhsContent && equalTypes(lhs: lhsTargetType, rhs: rhsTargetType)
        default: false
        }
    }
}

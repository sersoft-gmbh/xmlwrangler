/// The error type that is thrown for all lookup operations on `XMLElement`.
public enum LookupError: Error, CustomStringConvertible {
    case missingAttribute(element: XMLElement, key: XMLElement.Attributes.Key)
    case cannotConvertAttribute(element: XMLElement, key: XMLElement.Attributes.Key, type: Any.Type)

    case missingContent(element: XMLElement)
    case missingChild(element: XMLElement, childElementName: XMLElement.Name)
    case cannotConvertContent(element: XMLElement, content: XMLElement.Content.Element.StringPart, type: Any.Type)

    public var description: String {
        switch self {
        case .missingAttribute(let element, let key):
            return """
                Element '\(element.name.rawValue)' has no attribute '\(key.rawValue)'!
                Attributes: \(element.attributes)
                """
        case .cannotConvertAttribute(let element, let key, let targetType):
            return """
                Could not convert attribute '\(key.rawValue)' of element '\(element.name.rawValue)' to \(targetType)!
                Attribute value: \(element.attributes[key] ?? "nil")
                """

        case .missingContent(let element):
            return "Element '\(element.name.rawValue)' has no content!"
        case .missingChild(let element, let childElementName):
            return "Element '\(element.name.rawValue)' has no child named '\(childElementName.rawValue)'"
        case .cannotConvertContent(let element, let content, let targetType):
            return """
                Could not convert content of element '\(element.name.rawValue)' to \(targetType)!
                Content: \(content)
                """
        }
    }
}

extension XMLElement {
    /// The error type that is thrown for all lookup operations on ``XMLElement``.
    public enum LookupError: Error, CustomStringConvertible {
        /// Thrown when a given `element` is missing a child with the given `childName`.
        case missingChild(element: XMLElement, childName: XMLElement.Name)

        /// Thrown when an `element` is missing an attribute for a given `key`.
        case missingAttribute(element: XMLElement, key: XMLElement.Attributes.Key)
        /// Thrown when an attribute ``XMLElement/Attributes/Contents`` (for `key`) cannot be converted to a given `type`.
        case cannotConvertAttribute(element: XMLElement, key: XMLElement.Attributes.Key, content: XMLElement.Attributes.Content, type: Any.Type)

        /// Thrown when an element is missing string content.
        case missingStringContent(element: XMLElement)
        /// Thrown when the ``XMLElement/stringContent()`` of an `element` cannot be converted to a given `type`.
        case cannotConvertStringContent(element: XMLElement, stringContent: XMLElement.Content.Element.StringPart, type: Any.Type)

        public var description: String {
            switch self {
            case .missingAttribute(let element, let key):
            """
            Element '\(element.name.rawValue)' has no attribute '\(key.rawValue)'!
            Attributes: \(element.attributes)
            """
            case .cannotConvertAttribute(let element, let key, let content, let targetType):
            """
            Could not convert attribute '\(key.rawValue)' of element '\(element.name.rawValue)' to \(targetType)!
            Attribute content: \(content)
            """
            case .missingChild(let element, let childName):
                "Element '\(element.name.rawValue)' has no child named '\(childName.rawValue)'"
            case .missingStringContent(let element):
                "Element '\(element.name.rawValue)' has no string content!"
            case .cannotConvertStringContent(let element, let stringContent, let targetType):
            """
            Could not convert content of element '\(element.name.rawValue)' to \(targetType)!
            Element string content: \(stringContent)
            """
            }
        }
    }
}

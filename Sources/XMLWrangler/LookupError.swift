public enum LookupError: Error, CustomStringConvertible {
   case missingAttribute(element: Element, key: Element.AttributeKey)
   case cannotConvertAttribute(element: Element, key: Element.AttributeKey, type: Any.Type)

   case missingContent(element: Element)
   case missingChild(element: Element, childElementName: Element.Name)
   case cannotConvertContent(element: Element, content: String, type: Any.Type)

   public var description: String {
      switch self {
      case .missingAttribute(let element, let key):
         return "Element \"\(element.name.rawValue)\" has no attribute \"\(key.rawValue)\"!\nAttributes: \(element.attributes)"
      case .cannotConvertAttribute(let element, let key, let targetType):
         return "Could not convert attribute \"\(key.rawValue)\" of element \"\(element.name.rawValue)\" to \(targetType)!\nAttribute value: \(element.attributes[key] ?? "nil")"

      case .missingContent(let element):
         return "Element \"\(element.name.rawValue)\" has no content!"
      case .missingChild(let element, let childElementName):
         return "Element \"\(element.name.rawValue)\" has no child named \"\(childElementName.rawValue)\""
      case .cannotConvertContent(let element, let content, let targetType):
         return "Could not convert content of element \"\(element.name.rawValue)\" to \(targetType)!\nContent: \(content)"
      }
   }
}

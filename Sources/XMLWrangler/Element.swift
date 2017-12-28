public struct Element: Equatable, ExpressibleByStringLiteral {
   public typealias Attributes = Dictionary<AttributeKey, String>
   
   public let name: String
   public var attributes: Attributes = [:]
   public var content: [Content] = []
   
   public init(name: String, attributes: Attributes = [:], content: [Content] = []) {
      self.name = name
      self.attributes = attributes
      self.content = content
   }

   public init(name: String, attributes: Attributes = [:], content: Content...) {
      self.init(name: name, attributes: attributes, content: content)
   }
   
   public init(stringLiteral value: String) {
      self.name = value
   }
   
   public static func ==(lhs: Element, rhs: Element) -> Bool {
      return lhs.name == rhs.name && lhs.attributes == rhs.attributes && lhs.content == rhs.content
   }
}

public extension Element {
   public func convertedAttribute<T: LosslessStringConvertible>(for key: AttributeKey) -> T? {
      return attributes[key].flatMap(T.init)
   }
}

public extension Element {
   public struct AttributeKey: RawRepresentable, Hashable, ExpressibleByStringLiteral {
      public typealias RawValue = String
      public typealias StringLiteralType = RawValue

      public let rawValue: RawValue
      public var hashValue: Int { return rawValue.hashValue }

      public init(rawValue: RawValue) { self.rawValue = rawValue }
      public init(stringLiteral value: StringLiteralType) { self.init(rawValue: value) }
   }
}

public extension Element {
   public enum Content: Equatable, ExpressibleByArrayLiteral, ExpressibleByStringLiteral {
      case string(String)
      // TODO: Do we need a CDATA case, too?
      case objects([Element])
      
      public static func ==(lhs: Content, rhs: Content) -> Bool {
         switch (lhs, rhs) {
         //         case (.empty, .empty): return true
         case (.string(let lhsStr), .string(let rhsStr)): return lhsStr == rhsStr
         case (.objects(let lhsObjs), .objects(let rhsObjs)): return lhsObjs == rhsObjs
         default: return false
         }
      }
   }
}

public extension Element.Content {
   //   public init(nilLiteral: ()) {
   //      self = .empty
   //   }

   public init(stringLiteral value: String) {
      self = .string(value)
//      self = value.isEmpty ? .empty : .string(value)
   }
   
   public init(arrayLiteral elements: Element...) {
      self = .objects(elements)
//      self = elements.isEmpty ? .empty : .objects(elements)
   }
}

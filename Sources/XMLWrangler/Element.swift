public struct Element: Equatable, ExpressibleByStringLiteral {
   public typealias Attributes = Dictionary<AttributeKey, String>
   
   /// The name of the element.
   public let name: Name
   /// The attributes of the element.
   public var attributes: Attributes = [:]
   /// The content of the element.
   public var content: [Content] = []

   public init(name: Name, attributes: Attributes = [:], content: [Content] = []) {
      self.name = name
      self.attributes = attributes
      self.content = content
   }

   public init(name: Name, attributes: Attributes = [:], content: Content...) {
      self.init(name: name, attributes: attributes, content: content)
   }

   public init(name: Name, attributes: Attributes = [:], objects: [Element]) {
      self.init(name: name, attributes: attributes, content: objects.map { .object($0) })
   }

   public init(name: Name, attributes: Attributes = [:], objects: Element...) {
      self.init(name: name, attributes: attributes, objects: objects)
   }
   
   public init(stringLiteral value: Name.StringLiteralType) {
      self.init(name: .init(stringLiteral: value))
   }
   
   public static func ==(lhs: Element, rhs: Element) -> Bool {
      return lhs.name == rhs.name && lhs.attributes == rhs.attributes && lhs.content == rhs.content
   }
}

public extension Element {
   public struct Name: RawRepresentable, Hashable, ExpressibleByStringLiteral {
      public typealias RawValue = String
      public typealias StringLiteralType = RawValue

      public let rawValue: RawValue
      public var hashValue: Int { return rawValue.hashValue }

      public init(rawValue: RawValue) { self.rawValue = rawValue }
      public init(stringLiteral value: StringLiteralType) { self.init(rawValue: value) }
   }

   public struct AttributeKey: RawRepresentable, Hashable, ExpressibleByStringLiteral {
      public typealias RawValue = String
      public typealias StringLiteralType = RawValue

      public let rawValue: RawValue
      public var hashValue: Int { return rawValue.hashValue }

      public init(rawValue: RawValue) { self.rawValue = rawValue }
      public init(stringLiteral value: StringLiteralType) { self.init(rawValue: value) }
   }

   public enum Content: Equatable, ExpressibleByStringLiteral {
      case string(String)
      // TODO: Do we need a CDATA case, too?
      case object(Element)

      public init(stringLiteral value: String) {
         self = .string(value)
      }
      
      public static func ==(lhs: Content, rhs: Content) -> Bool {
         switch (lhs, rhs) {
         case (.string(let lhsStr), .string(let rhsStr)): return lhsStr == rhsStr
         case (.object(let lhsObj), .object(let rhsObj)): return lhsObj == rhsObj
         default: return false
         }
      }
   }
}

public struct Element: Equatable, ExpressibleByStringLiteral {
   public typealias UnicodeScalarLiteralType = StringLiteralType
   public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType

   public let name: String
   public var attributes: Dictionary<String, String> = [:]
   public var content: Content = nil

   public init(name: String, attributes: Dictionary<String, String> = [:], content: Content = nil) {
      self.name = name
      self.attributes = attributes
      self.content = content
   }

   public init(stringLiteral value: String) {
      self.name = value
   }

   public static func ==(lhs: Element, rhs: Element) -> Bool {
      return lhs.name == rhs.name && lhs.attributes == rhs.attributes && lhs.content == rhs.content
   }
}

public extension Element {
   public enum Content: Equatable, ExpressibleByNilLiteral, ExpressibleByArrayLiteral, ExpressibleByStringLiteral {
      public typealias UnicodeScalarLiteralType = StringLiteralType
      public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType

      case empty
      case string(String)
      // TODO: Do we need a CDATA case, too?
      case objects([Element])

      public static func ==(lhs: Content, rhs: Content) -> Bool {
         switch (lhs, rhs) {
         case (.empty, .empty): return true
         case (.string(let lhsStr), .string(let rhsStr)): return lhsStr == rhsStr
         case (.objects(let lhsObjs), .objects(let rhsObjs)): return lhsObjs == rhsObjs
         default: return false
         }
      }
   }
}

public extension Element.Content {
   public init(nilLiteral: ()) {
      self = .empty
   }

   public init(stringLiteral value: String) {
      self = value.isEmpty ? .empty : .string(value)
   }

   public init(arrayLiteral elements: Element...) {
      self = elements.isEmpty ? .empty : .objects(elements)
   }
}

public extension Element.Content {
   public mutating func append(string: String, convertIfNecessary: Bool = false) {
      guard case .string(let str) = self else {
         if convertIfNecessary { self = .string(string) }
         return
      }
      self = .string(str + string)
   }

   public mutating func append(object: Element, convertIfNecessary: Bool = false) {
      guard case .objects(let objs) = self else {
         if convertIfNecessary { self = .objects([object]) }
         return
      }
      self = .objects(objs + [object])
   }

   public mutating func append(contentsOf objects: [Element], convertIfNecessary: Bool = false) {
      guard case .objects(let objs) = self else {
         if convertIfNecessary { self = .objects(objects) }
         return
      }
      self = .objects(objs + objects)
   }
}

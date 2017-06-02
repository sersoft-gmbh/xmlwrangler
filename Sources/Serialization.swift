import SemVer

public struct SerializationOptions: OptionSet {
   public typealias RawValue = Int
   
   public let rawValue: RawValue
   public init(rawValue: RawValue) {
      self.rawValue = rawValue
   }
}

public extension SerializationOptions {
   public static let pretty: SerializationOptions = .init(rawValue: 1 << 0)
}

fileprivate extension SerializationOptions {
   fileprivate var lineSeparator: String {
      return contains(.pretty) ? "\n" : ""
   }
}

public enum DocumentEncoding: Hashable, CustomStringConvertible {
   case utf8
   case utf16
   case ascii
    
   public var description: String {
      switch self {
      case .utf8: return "utf-8"
      case .utf16: return "utf-16"
      case .ascii: return "ascii"
      }
   }
   
   fileprivate var attributeValue: String {
      switch self {
      case .utf8: return "UTF-8"
      case .utf16: return "UTF-16"
      case .ascii: return "ASCII"
      }
   }
}

public enum EscapableContent: Equatable {
   fileprivate typealias Replacement = (unescaped: String, escaped: String)
   
   public enum Quotes: Equatable {
      case single
      case double
   }
   
   // See: https://stackoverflow.com/questions/1091945/what-characters-do-i-need-to-escape-in-xml-documents
   case attribute(quotes: Quotes)
   case comment
   case text
   case cdata
   case processingInstruction
   
   // See: https://en.wikipedia.org/wiki/XML#Escaping
   fileprivate var replacements: [Replacement] {
      let ampersandReplacement = ("&", "&amp;")
      let doubleQuoteReplacement = ("\"", "&quot;")
      let singleQuoteReplacement = ("'", "&apos;")
      let lessThanReplacement = ("<", "&lt;")
//      let greaterThanReplacement = (">", "&gt;")
      
      // In each of these, order is very important. & always needs to get escaped first!
      switch self {
      case .attribute(let quotes):
         switch quotes {
         case .single:
            return [ampersandReplacement, singleQuoteReplacement, lessThanReplacement]
         case .double:
            return [ampersandReplacement, doubleQuoteReplacement, lessThanReplacement]
         }
      case .comment:
         return []
      case .text:
         return [ampersandReplacement, lessThanReplacement]
      case .cdata:
         return []
      case .processingInstruction:
         return []
      }
   }
   
   public static func ==(lhs: EscapableContent, rhs: EscapableContent) -> Bool {
      switch (lhs, rhs) {
      case (.attribute(let lhsQuotes), .attribute(let rhsQuotes)):
         return lhsQuotes == rhsQuotes
      case (.comment, .comment),
           (.text, .text),
           (.cdata, .cdata):
         return true
      default:
         return false
      }
   }
}

public extension String {
   public func escaped(content: EscapableContent) -> String {
      return content.replacements.reduce(self) {
         $0.replacingOccurrences(of: $1.unescaped, with: $1.escaped)
      }
   }
   
   public mutating func escape(content: EscapableContent) {
      self = escaped(content: content)
   }
}

public extension String {
    public init(xmlDocumentRoot root: Element, version: Version = Version(major: 1), encoding: DocumentEncoding = .utf8, options: SerializationOptions = []) {
      let versionAttribute = "version=\"" + version.versionString().escaped(content: .attribute(quotes: .double)) + "\""
      let encodingAttribute = "encoding=\"" + encoding.attributeValue.escaped(content: .attribute(quotes: .double)) + "\""
      self = "<?xml \(versionAttribute) \(encodingAttribute)?>"
         + options.lineSeparator
         + String(xml: root)
         + options.lineSeparator
   }
   
   public init(xml: Element, options: SerializationOptions = []) {
      let attributes = xml.attributes.isEmpty ? "" : " " + xml.attributes.map {
         $0.key + "=\"" + $0.value.escaped(content: .attribute(quotes: .double)) + "\""
      }.joined(separator: " ")
      let start = "<\(xml.name)\(attributes)"
      let end = "</\(xml.name)>"
      switch xml.content {
      case .empty:
         self = start + "/>"
      case .string(let str):
         self = start + ">"
            + options.lineSeparator
            + str.escaped(content: .text)
            + options.lineSeparator
            + end
      case .objects(let objs):
         self = start + ">"
            + options.lineSeparator
            + objs.map { String(xml: $0, options: options) }.joined(separator: options.lineSeparator)
            + end
      }
   }
}

@_exported import struct SemVer.Version

/// Represents options to use for serializing xml elements.
public struct SerializationOptions: OptionSet {
   public typealias RawValue = Int

   public let rawValue: RawValue
   public init(rawValue: RawValue) {
      self.rawValue = rawValue
   }
}

public extension SerializationOptions {
   /// Use pretty formatting (by adding newlines between elements).
   public static let pretty: SerializationOptions = .init(rawValue: 1 << 0)

   /// Use single quotes (') instead of double quotes (") for attribute values.
   public static let singleQuoteAttributes: SerializationOptions = .init(rawValue: 1 << 1)
}

fileprivate extension SerializationOptions {
   fileprivate var lineSeparator: String {
      return contains(.pretty) ? "\n" : ""
   }

   fileprivate var quotes: EscapableContent.Quotes {
      return contains(.singleQuoteAttributes) ? .single : .double
   }
}

/// The encoding of an XML document.
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

/// Represents a type of content that can be escaped.
public enum EscapableContent: Equatable, CustomStringConvertible {
   fileprivate typealias Replacement = (unescaped: String, escaped: String)

   public enum Quotes: Equatable, CustomStringConvertible {
      case single
      case double

      public var description: String {
         switch self {
         case .single:
            return "Single quotes"
         case .double:
            return "Double quotes"
         }
      }

      private var quoteChar: String {
         switch self {
         case .single: return "'"
         case .double: return "\""
         }
      }

      fileprivate func quoted(attributeString string: String) -> String {
         return quoteChar + string.escaped(content: .attribute(quotes: self)) + quoteChar
      }
   }

   // See: https://stackoverflow.com/questions/1091945/what-characters-do-i-need-to-escape-in-xml-documents
   case attribute(quotes: Quotes)
   case text
   case cdata
   case comment
   case processingInstruction

   public var description: String {
      switch self {
      case .attribute(let quotes):
         return "Attribute enclosed in \(quotes)"
      case .text:
         return "Text"
      case .cdata:
         return "CDATA"
      case .comment:
         return "Comment"
      case .processingInstruction:
         return "Processing instruction"
      }
   }

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
      case .text:
         return [ampersandReplacement, lessThanReplacement]
      case .cdata:
         return []
      case .comment:
         return []
      case .processingInstruction:
         return []
      }
   }

   public static func ==(lhs: EscapableContent, rhs: EscapableContent) -> Bool {
      switch (lhs, rhs) {
      case (.attribute(let lhsQuotes), .attribute(let rhsQuotes)):
         return lhsQuotes == rhsQuotes
      case (.text, .text),
           (.cdata, .cdata),
           (.comment, .comment):
         return true
      default:
         return false
      }
   }
}

fileprivate extension Version {
   var xmlVersionString: String {
      return "\(major).\(minor)"
   }
}

public extension String {
   /// Returns a string which is escaped following the rules for the EscapableContent passed in.
   ///
   /// - Parameter content: The type of content for which the escaped string is to be used.
   /// - Returns: An escaped string following the escaping rules for `content`.
   public func escaped(content: EscapableContent) -> String {
      return content.replacements.reduce(self) {
         $0.replacingOccurrences(of: $1.unescaped, with: $1.escaped)
      }
   }

   /// Escapes the receiver following the rules for the EscapableContent passed in.
   ///
   /// - Parameter content: The type of content for which the escaped string is to be used.
   public mutating func escape(content: EscapableContent) {
      self = escaped(content: content)
   }
}

public extension String {
    /// Creates a String by serializing an xml element as root and adding the <?xml ...?> document header.
    ///
    /// - Parameters:
    ///   - root: The root object for the xml document.
    ///   - version: The version of the xml document. Only major and minor are used since XML only supports these. Defaults to 1.0.
    ///   - encoding: The encoding for the document. Defaults to utf-8.
    ///   - options: The options to use for serializing. Defaults to empty options.
    /// - SeeAlso: `String.init(xml:options:)`
   public init(xmlDocumentRoot root: XMLWrangler.Element, version: Version = Version(major: 1), encoding: DocumentEncoding = .utf8, options: SerializationOptions = []) {
      let versionAttribute = "version=" + options.quotes.quoted(attributeString: version.xmlVersionString)
      let encodingAttribute = "encoding=" + options.quotes.quoted(attributeString: encoding.attributeValue)
      self = "<?xml \(versionAttribute) \(encodingAttribute)?>"
         + options.lineSeparator
         + String(xml: root, options: options)
   }

   /// Creates a String by serializing an xml element.
   ///
   /// - Parameters:
   ///   - xml: The xml element to serialize.
   ///   - options: The options to use for serializing. Defaults to empty options.
   public init(xml: XMLWrangler.Element, options: SerializationOptions = []) {
      let attributes = xml.attributes.isEmpty ? "" : " " + xml.attributes.map {
         $0.key + "=" + options.quotes.quoted(attributeString: $0.value)
      }.joined(separator: " ")
      let start = "<\(xml.name)\(attributes)"
      let end = "</\(xml.name)>"
      switch xml.content {
      case .empty:
         self = start + "/>"
      case .string(let str):
         self = start + ">"
            + str.escaped(content: .text)
            + end
      case .objects(let objs):
         self = start + ">"
            + options.lineSeparator
            + objs.map { String(xml: $0, options: options) }.joined()
            + end
      }
      self += options.lineSeparator
   }
}

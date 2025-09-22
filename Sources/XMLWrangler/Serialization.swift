fileprivate import Foundation

extension XMLElement {
    /// Represents the version of an XML document.
    public struct DocumentVersion: Sendable, Hashable, Comparable, CustomStringConvertible {
        /// The major version of the document.
        public var major: Int
        /// The minor version of the document.
        public var minor: Int

        @usableFromInline
        var versionString: String {
            "\(major).\(minor)"
        }

        @inlinable
        public var description: String {
            versionString
        }

        /// Creates a new XML version using the given parts.
        /// - Parameters:
        ///   - major: The major part.
        ///   - minor: The minor part.
        public init(major: Int, minor: Int = 0) {
            self.major = major
            self.minor = minor
        }

        public static func <(lhs: Self, rhs: Self) -> Bool {
            (lhs.major, lhs.minor) < (rhs.major, rhs.minor)
        }
    }

    /// Represents options to use for serializing XML elements.
    @frozen
    public struct SerializationOptions: OptionSet, Sendable {
        public typealias RawValue = UInt

        public let rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }

    /// The encoding of an XML document.
    public struct DocumentEncoding: Sendable, RawRepresentable, Hashable, CustomStringConvertible {
        public typealias RawValue = String

        public let rawValue: RawValue

        public var description: String { rawValue }

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }

    /// Represents a type of content that can be escaped.
    public enum EscapableContent: Sendable, Hashable, CustomStringConvertible {
        fileprivate typealias Replacement = (unescaped: String, escaped: String)

        /// Represents the type of quotes to be used for quoting.
        public enum Quotes: Sendable, Hashable, CustomStringConvertible {
            case single, double

            public var description: String {
                switch self {
                case .single: "Single quotes"
                case .double: "Double quotes"
                }
            }

            private var quoteChar: String {
                switch self {
                case .single: "'"
                case .double: "\""
                }
            }

            fileprivate func quotedAttributeString(_ string: some StringProtocol) -> String {
                let char = quoteChar
                return char + EscapableContent.attribute(quotes: self).escape(string) + char
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
            case .attribute(let quotes): "Attribute enclosed in \(String(describing: quotes).lowercased())"
            case .text: "Text"
            case .cdata: "CDATA"
            case .comment: "Comment"
            case .processingInstruction: "Processing instruction"
            }
        }

        // See: https://en.wikipedia.org/wiki/XML#Escaping
        fileprivate var replacements: Array<Replacement> {
            lazy var ampersandReplacement = ("&", "&amp;")
            lazy var doubleQuoteReplacement = ("\"", "&quot;")
            lazy var singleQuoteReplacement = ("'", "&apos;")
            lazy var lessThanReplacement = ("<", "&lt;")
            // lazy var greaterThanReplacement = (">", "&gt;")

            // In each of these, order is very important. & always needs to get escaped first!
            return switch self {
            case .attribute(.single): [ampersandReplacement, singleQuoteReplacement, lessThanReplacement]
            case .attribute(.double): [ampersandReplacement, doubleQuoteReplacement, lessThanReplacement]
            case .text: [ampersandReplacement, lessThanReplacement]
            case .cdata, .comment, .processingInstruction: []
            }
        }

        /// Returns a string which is escaped following the rules defined by the receiver.
        /// - Parameter string: The string to escae.
        /// - Returns: The escaped string.
        public func escape(_ string: some StringProtocol) -> String {
            replacements.reduce(String(string)) {
                $0.replacingOccurrences(of: $1.unescaped, with: $1.escaped)
            }
        }
    }
}

extension XMLElement.SerializationOptions {
    /// Use pretty formatting (by adding newlines between elements).
    public static let pretty = XMLElement.SerializationOptions(rawValue: 1 << 0)

    /// Use single quotes (`'`) instead of double quotes (`"`) for attribute values.
    public static let singleQuoteAttributes = XMLElement.SerializationOptions(rawValue: 1 << 1)

    /// Serialize empty elements with an explicit closing tag (e.g. `<elem></elem>` instead of `<elem/>`).
    public static let explicitClosingTag = XMLElement.SerializationOptions(rawValue: 1 << 2)
}

extension XMLElement.DocumentEncoding {
    /// The UTF-8 document encoding.
    public static let utf8 = XMLElement.DocumentEncoding(rawValue: "UTF-8")
    /// The UTF-16 document encoding.
    public static let utf16 = XMLElement.DocumentEncoding(rawValue: "UTF-16")
    /// The ASCII document encoding.
    public static let ascii = XMLElement.DocumentEncoding(rawValue: "ASCII")
}

extension XMLElement.SerializationOptions {
    fileprivate var lineSeparator: String {
        contains(.pretty) ? "\n" : ""
    }

    fileprivate var quotes: XMLElement.EscapableContent.Quotes {
        contains(.singleQuoteAttributes) ? .single : .double
    }
}

extension XMLElement.Content {
    /// Creates a String by serializing the XML content.
    /// - Parameters:
    ///   - options: The options to use for serializing. Defaults to empty options.
    public func serialize(with options: XMLElement.SerializationOptions = []) -> String {
        let (contentStr, didContainElementsOrMultilineStrings) = compressed().reduce(into: ("", false)) {
            switch $1 {
            case .string(let str):
                let hasNewlines = str.contains(where: \.isNewline)
                $0.1 = $0.1 || hasNewlines
                $0.0 += XMLElement.EscapableContent.text.escape(str) + (hasNewlines ? options.lineSeparator : "")
            case .element(let obj):
                $0.1 = true
                $0.0 += obj.serialize(with: options) + options.lineSeparator
            }
        }
        return didContainElementsOrMultilineStrings ? options.lineSeparator + contentStr : contentStr
    }
}

extension XMLElement {
    /// Creates a String by serializing the XML element.
    /// - Parameters:
    ///   - options: The options to use for serializing. Defaults to empty options.
    public func serialize(with options: SerializationOptions = []) -> String {
        let attributes = attributes.storage.isEmpty ? "" : " " + attributes.storage.map {
            "\($0.key.rawValue)=\(options.quotes.quotedAttributeString($0.value.rawValue))"
        }.joined(separator: " ")
        let start = "<\(name.rawValue)\(attributes)"
        let content = content.serialize(with: options)
        return content.isEmpty && !options.contains(.explicitClosingTag)
        ? "\(start)/>"
        : "\(start)>\(content)</\(name.rawValue)>"
    }

    /// Creates a String by serializing the XML element as root and adding the `<?xml ...?>` document header.
    /// - Parameters:
    ///   - version: The version of the document. Defaults to `"1.0"`.
    ///   - encoding: The encoding for the document. Defaults to ``XMLElement/DocumentEncoding/utf8``.
    ///   - options: The options to use for serializing. Defaults to empty options.
    /// - SeeAlso: ``XMLElement/serialize(with:)``
    public func serializeAsDocument(at version: DocumentVersion = .init(major: 1),
                                    in encoding: DocumentEncoding = .utf8,
                                    with options: SerializationOptions = []) -> String {
        let versionAttribute = "version=" + options.quotes.quotedAttributeString(version.versionString)
        let encodingAttribute = "encoding=" + options.quotes.quotedAttributeString(encoding.rawValue)
        return "<?xml \(versionAttribute) \(encodingAttribute)?>" + options.lineSeparator + serialize(with: options)
    }
}

extension XMLElementConvertible {
    /// Creates a String by serializing the ``xml`` element.
    /// - Parameters:
    ///   - options: The options to use for serializing. Defaults to empty options.
    /// - SeeAlso: ``XMLElement/serialize(with:)``
    @inlinable
    public func serializeAsXML(with options: XMLElement.SerializationOptions = []) -> String {
        xml.serialize(with: options)
    }

    /// Creates an XML String by serializing the ``xml``  as root and adding the `<?xml ...?>` document header.
    /// - Parameters:
    ///   - version: The version of the document. Defaults to `"1.0"`.
    ///   - encoding: The encoding for the document. Defaults to ``XMLElement/DocumentEncoding/utf8``.
    ///   - options: The options to use for serializing. Defaults to empty options.
    /// - SeeAlso: ``XMLElement/serializeAsXMLDocument(at:in:with:)``
    @inlinable
    public func serializeAsXMLDocument(at version: XMLElement.DocumentVersion = .init(major: 1),
                                       in encoding: XMLElement.DocumentEncoding = .utf8,
                                       with options: XMLElement.SerializationOptions = []) -> String {
        xml.serializeAsDocument(at: version, in: encoding, with: options)
    }
}

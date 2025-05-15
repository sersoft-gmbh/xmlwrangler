/// Represents an element in an XML structure.
public struct XMLElement: Sendable, Equatable, Identifiable, CustomStringConvertible, CustomDebugStringConvertible {
    /// The name of the element.
    public let name: Name
    /// The attributes of the element.
    public var attributes: Attributes
    /// The content of the element.
    public var content: Content

    @inlinable
    public var id: Name { name }

    public var description: String {
        "XMLElement '\(name)' { \(attributes.storage.count) attribute(s), \(content.storage.count) content element(s) }"
    }

    public var debugDescription: String {
        """
        XMLElement '\(name.debugDescription)' {
        attributes: \(attributes.debugDescription)
        contents: \(content.debugDescription)
        }
        """
    }

    /// Creates a new element using the given parameters.
    /// - Parameters:
    ///   - name: The name of the new element.
    ///   - attributes: The attributes of the new element (defaults to empty attributes).
    ///   - content: The content of the new element (defaults to empty contents).
    public init(name: Name, attributes: Attributes = .init(), content: Content = .init()) {
        self.name = name
        self.attributes = attributes
        self.content = content
    }

    /// Creates a new element using the given parameters.
    /// - Parameters:
    ///   - name: The name of the new element.
    ///   - attributes: The attributes of the new element (defaults to empty attributes).
    ///   - content: The variadic list of content elements for the new element.
    @inlinable
    public init(name: Name, attributes: Attributes = .init(), content: Content.Element...) {
        self.init(name: name, attributes: attributes, content: .init(storage: content))
    }

    /// Creates a new element using the given parameters.
    /// - Parameters:
    ///   - name: The name of the new element.
    ///   - attributes: The attributes of the new element (defaults to empty attributes).
    ///   - elements: A sequence of ``XMLElement``s to use as content for the new element.
    @inlinable
    public init(name: Name, attributes: Attributes = .init(), elements: some Sequence<XMLElement>) {
        self.init(name: name, attributes: attributes, content: .init(storage: elements.map { .element($0) }))
    }

    /// Creates a new element using the given parameters.
    /// - Parameters:
    ///   - name: The name of the new element.
    ///   - attributes: The attributes of the new element (defaults to empty attributes).
    ///   - elements: A variadic list of ``XMLElement``s to use as content for the new element.
    @inlinable
    public init(name: Name, attributes: Attributes = .init(), elements: XMLElement...) {
        self.init(name: name, attributes: attributes, elements: elements)
    }

    /// Creates a new element using the given parameters.
    /// - Parameters:
    ///   - name: The name of the new element.
    ///   - attributes: The attributes of the new element (defaults to empty attributes).
    ///   - stringContent: The string content for the new element.
    @inlinable
    public init(name: Name, attributes: Attributes = .init(), stringContent: Content.Element.StringPart) {
        self.init(name: name, attributes: attributes, content: .string(stringContent))
    }
}

extension XMLElement: XMLElementRepresentable {
    @inlinable
    public var xml: XMLElement { self }

    @inlinable
    public init(xml: XMLElement) { self = xml }
}

extension XMLElement {
    /// Represents the name of an element.
    @frozen
    public struct Name: RawRepresentable,
                        Hashable,
                        Codable,
                        Sendable,
                        ExpressibleByStringLiteral,
                        XMLAttributeContentRepresentable,
                        CustomStringConvertible,
                        CustomDebugStringConvertible
    {
        public typealias RawValue = String
        public typealias StringLiteralType = RawValue

        public let rawValue: RawValue

        public var description: String { rawValue }
        public var debugDescription: String { "\(Self.self)(\(rawValue))" }

        public init(rawValue: RawValue) { self.rawValue = rawValue }

        /// Creates a new name using the given raw value.
        @inlinable
        public init(_ rawValue: RawValue) { self.init(rawValue: rawValue) }

        @inlinable
        public init(stringLiteral value: StringLiteralType) { self.init(rawValue: value) }
    }
}

/// A typealias for ``XMLWrangler/XMLElement``.
/// Use this if you run into conflicts with `Foundation/XMLElement`.
public typealias XWElement = XMLElement

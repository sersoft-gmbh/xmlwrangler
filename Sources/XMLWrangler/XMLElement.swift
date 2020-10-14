/// Represents an element in an XML structure.
public struct XMLElement: Equatable, Identifiable {
    /// The name of the element.
    public let name: Name
    /// The attributes of the element.
    public var attributes: Attributes = [:]
    /// The content of the element.
    public var content: Content = []

    /// inherited
    @inlinable
    public var id: Name { name }

    /// Creates a new element using the given parameters.
    /// - Parameters:
    ///   - name: The name of the new element.
    ///   - attributes: The attributes of the new element (defaults to empty attributes).
    ///   - content: The content of the new element (defaults to empty contents).
    public init(name: Name, attributes: Attributes = [:], content: Content = []) {
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
    public init(name: Name, attributes: Attributes = [:], content: Content.Element...) {
        self.init(name: name, attributes: attributes, content: .init(storage: content))
    }

    /// Creates a new element using the given parameters.
    /// - Parameters:
    ///   - name: The name of the new element.
    ///   - attributes: The attributes of the new element (defaults to empty attributes).
    ///   - elements: A sequence of `XMLElement`s to use as content for the new element.
    @inlinable
    public init<Elements>(name: Name, attributes: Attributes = [:], elements: Elements)
    where Elements: Sequence, Elements.Element == XMLElement
    {
        self.init(name: name, attributes: attributes, content: .init(storage: elements.map { .element($0) }))
    }

    /// Creates a new element using the given parameters.
    /// - Parameters:
    ///   - name: The name of the new element.
    ///   - attributes: The attributes of the new element (defaults to empty attributes).
    ///   - elements: A variadic list of `XMLElement`s to use as content for the new element.
    @inlinable
    public init(name: Name, attributes: Attributes = [:], elements: XMLElement...) {
        self.init(name: name, attributes: attributes, elements: elements)
    }

    /// Creates a new element using the given parameters.
    /// - Parameters:
    ///   - name: The name of the new element.
    ///   - attributes: The attributes of the new element (defaults to empty attributes).
    ///   - stringContent: The string content for the new element.
    @inlinable
    public init(name: Name, attributes: Attributes = [:], stringContent: Content.Element.StringPart) {
        self.init(name: name, attributes: attributes, content: .string(stringContent))
    }
}

extension XMLElement {
    /// Represents the name of an element.
    @frozen
    public struct Name: RawRepresentable, Hashable, Codable, ExpressibleByStringLiteral {
        public typealias RawValue = String
        public typealias StringLiteralType = RawValue

        /// inherited
        public let rawValue: RawValue

        /// inherited
        public init(rawValue: RawValue) { self.rawValue = rawValue }

        /// Creates a new name using the given raw value.
        @inlinable
        public init(_ rawValue: RawValue) { self.init(rawValue: rawValue) }

        /// inherited
        @inlinable
        public init(stringLiteral value: StringLiteralType) { self.init(rawValue: value) }
    }
}

/// A typealias for `XMLWrangler.XWElement`.
/// Use this if you run into conflicts with `Foundation.XMLElement`.
public typealias XWElement = XMLElement

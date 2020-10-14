/// Represents an element in an XML structure.
public struct XMLElement: Equatable {
    /// The name of the element.
    public let name: Name
    /// The attributes of the element.
    public var attributes: Attributes = [:]
    /// The content of the element.
    public var content: Content = []

    public init(name: Name, attributes: Attributes = [:], content: Content = []) {
        self.name = name
        self.attributes = attributes
        self.content = content
    }

    @inlinable
    public init(name: Name, attributes: Attributes = [:], content: Content.Element...) {
        self.init(name: name, attributes: attributes, content: .init(storage: content))
    }

    @inlinable
    public init(name: Name, attributes: Attributes = [:], elements: [XMLElement]) {
        self.init(name: name, attributes: attributes, content: .init(storage: elements.map { .element($0) }))
    }

    @inlinable
    public init(name: Name, attributes: Attributes = [:], elements: XMLElement...) {
        self.init(name: name, attributes: attributes, elements: elements)
    }

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

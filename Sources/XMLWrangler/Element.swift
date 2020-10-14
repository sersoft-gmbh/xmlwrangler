/// Represents an element in an XML structure.
public struct Element: Equatable {
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
    public init(name: Name, attributes: Attributes = [:], objects: [Element]) {
        self.init(name: name, attributes: attributes, content: .init(storage: objects.map { .object($0) }))
    }

    @inlinable
    public init(name: Name, attributes: Attributes = [:], objects: Element...) {
        self.init(name: name, attributes: attributes, objects: objects)
    }

    @inlinable
    public init(name: Name, attributes: Attributes = [:], stringContent: String) {
        self.init(name: name, attributes: attributes, content: .string(stringContent))
    }
}

extension Element {
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

/// A typealias for `XMLWrangler.Element`.
public typealias XMLElement = Element

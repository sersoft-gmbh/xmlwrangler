public struct Element: Equatable, ExpressibleByStringLiteral {
    public typealias Attributes = Dictionary<AttributeKey, AttributeValue>

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

    @inlinable
    public init(name: Name, attributes: Attributes = [:], content: Content...) {
        self.init(name: name, attributes: attributes, content: content)
    }

    @inlinable
    public init(name: Name, attributes: Attributes = [:], objects: [Element]) {
        self.init(name: name, attributes: attributes, content: objects.map { .object($0) })
    }

    @inlinable
    public init(name: Name, attributes: Attributes = [:], objects: Element...) {
        self.init(name: name, attributes: attributes, objects: objects)
    }

    @inlinable
    public init(name: Name, attributes: Attributes = [:], stringContent: String) {
        self.init(name: name, attributes: attributes, content: .string(stringContent))
    }

    @inlinable
    public init(stringLiteral value: Name.StringLiteralType) {
        self.init(name: .init(stringLiteral: value))
    }
}

extension Element {
    @frozen
    public struct Name: RawRepresentable, Hashable, ExpressibleByStringLiteral {
        public typealias RawValue = String
        public typealias StringLiteralType = RawValue

        public let rawValue: RawValue

        public init(rawValue: RawValue) { self.rawValue = rawValue }

        @inlinable
        public init(_ rawValue: RawValue) { self.init(rawValue: rawValue) }

        @inlinable
        public init(stringLiteral value: StringLiteralType) { self.init(rawValue: value) }
    }

    @frozen
    public struct AttributeKey: RawRepresentable, Hashable, ExpressibleByStringLiteral {
        public typealias RawValue = String
        public typealias StringLiteralType = RawValue

        public let rawValue: RawValue

        public init(rawValue: RawValue) { self.rawValue = rawValue }

        @inlinable
        public init(_ rawValue: RawValue) { self.init(rawValue: rawValue) }

        @inlinable
        public init(stringLiteral value: StringLiteralType) { self.init(rawValue: value) }
    }

    @frozen
    public struct AttributeValue: RawRepresentable, Hashable, ExpressibleByStringLiteral {
        public typealias RawValue = String
        public typealias StringLiteralType = RawValue

        public let rawValue: RawValue

        public init(rawValue: RawValue) { self.rawValue = rawValue }

        @inlinable
        public init(_ rawValue: RawValue) { self.init(rawValue: rawValue) }

        @inlinable
        public init(stringLiteral value: StringLiteralType) { self.init(rawValue: value) }
    }

    public enum Content: Equatable, ExpressibleByStringLiteral {
        case string(String)
        // TODO: Do we need a CDATA case, too?
        case object(Element)

        public init(stringLiteral value: String) {
            self = .string(value)
        }
    }
}

public typealias XMLElement = Element

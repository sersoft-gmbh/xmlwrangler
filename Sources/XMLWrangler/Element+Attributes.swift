/// Describes a type that can turn itself into an `XMLElement.Attributes.Content`
public protocol XMLAttributeContentConvertible {
    /// The attribute content of this type.
    var xmlAttributeContent: XMLElement.Attributes.Content { get }
}

public protocol ExpressibleByXMLAttributeContent {
    init(xmlAttributeContent: XMLElement.Attributes.Content) throws
}

public typealias XMLAttributeContentRepresentable = ExpressibleByXMLAttributeContent & XMLAttributeContentConvertible

extension String: XMLAttributeContentConvertible {
    @inlinable
    public var xmlAttributeContent: XMLElement.Attributes.Content { .init(self) }
}

extension RawRepresentable where RawValue == XMLElement.Attributes.Content.RawValue, Self: XMLAttributeContentConvertible {
    @inlinable
    public var xmlAttributeContent: XMLElement.Attributes.Content { .init(rawValue) }
}

extension Element {
    @frozen
    public struct Attributes: Equatable {
        @frozen
        public struct Key: RawRepresentable, Hashable, Codable, ExpressibleByStringLiteral, XMLAttributeContentConvertible {
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
        public struct Content: RawRepresentable, Hashable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation, XMLAttributeContentConvertible {
            public typealias RawValue = String
            public typealias StringLiteralType = RawValue

            public let rawValue: RawValue

            @inlinable
            public var xmlAttributeValue: Content { self }

            public init(rawValue: RawValue) { self.rawValue = rawValue }

            @inlinable
            public init(_ rawValue: RawValue) { self.init(rawValue: rawValue) }

            @inlinable
            public init(stringLiteral value: StringLiteralType) { self.init(rawValue: value) }
        }

        @usableFromInline
        typealias Storage = Dictionary<Key, Content>

        @usableFromInline
        var storage: Storage

        @inlinable
        public var keys: Keys { .init(storage: storage.keys) }

        @inlinable
        public var contents: Contents {
            get { .init(storage: storage.values) }
            set { storage.values = newValue.storage }
        }

        @usableFromInline
        init(storage: Storage) {
            self.storage = storage
        }

        @inlinable
        public init() {
            self.init(storage: .init())
        }

        public init(minimumCapacity: Int) {
            self.init(storage: .init(minimumCapacity: minimumCapacity))
        }

        @inlinable
        public init<S>(uniqueKeysWithContents keysAndContents: S) where S: Sequence, S.Element == (Key, Content) {
            self.init(storage: .init(uniqueKeysWithValues: keysAndContents))
        }

        @inlinable
        public init<S>(_ keysAndContents: S, uniquingKeysWith combine: (Content, Content) throws -> Content) rethrows
        where S: Sequence, S.Element == (Key, Content)
        {
            try self.init(storage: .init(keysAndContents, uniquingKeysWith: combine))
        }

        @inlinable
        public subscript(_ key: Key) -> Content? {
            get { storage[key] }
            set { storage[key] = newValue }
        }

        @inlinable
        public subscript<Default: XMLAttributeContentConvertible>(_ key: Key, default defaultValue: @autoclosure () -> Default) -> Content {
            get { storage[key, default: defaultValue().xmlAttributeContent] }
            set { storage[key, default: defaultValue().xmlAttributeContent] = newValue }
        }

        @inlinable
        public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self {
            try .init(storage: storage.filter(isIncluded))
        }

        @inlinable
        public mutating func updateContent(_ content: Content, forKey key: Key) -> Content? {
            storage.updateValue(content, forKey: key)
        }

        @inlinable
        public mutating func merge<S>(_ other: S, uniquingKeysWith combine: (Content, Content) throws -> Content) rethrows
        where S: Sequence, S.Element == (Key, Content)
        {
            try storage.merge(other, uniquingKeysWith: combine)
        }

        @inlinable
        public mutating func merge(_ other: Self, uniquingKeysWith combine: (Content, Content) throws -> Content) rethrows {
            try storage.merge(other.storage, uniquingKeysWith: combine)
        }

        @inlinable
        public func merging<S>(_ other: S, uniquingKeysWith combine: (Content, Content) throws -> Content) rethrows -> Self
        where S: Sequence, S.Element == (Key, Content)
        {
            try .init(storage: storage.merging(other, uniquingKeysWith: combine))
        }

        @inlinable
        public func merging(_ other: Self, uniquingKeysWith combine: (Content, Content) throws -> Content) rethrows -> Self {
            try .init(storage: storage.merging(other.storage, uniquingKeysWith: combine))
        }
    }
}

extension Dictionary where Key == XMLElement.Attributes.Key, Value == XMLElement.Attributes.Content {
    @inlinable
    public init(_ attributes: XMLElement.Attributes) {
        self = attributes.storage
    }
}

extension Element.Attributes: ExpressibleByDictionaryLiteral {
    @inlinable
    public init(dictionaryLiteral elements: (Key, XMLAttributeContentConvertible)...) {
        self.init(storage: .init(uniqueKeysWithValues: elements.lazy.map { ($0, $1.xmlAttributeContent) }))
    }
}

extension Element.Attributes: Sequence {
    public typealias Element = (key: Key, content: Content)

    @inlinable
    static func _castElement(_ storageElement: Storage.Element) -> Element {
        unsafeBitCast(storageElement, to: Element.self)
    }

    @frozen
    public struct Iterator: IteratorProtocol {
        private var storageIterator: Storage.Iterator

        @usableFromInline
        init(base: Storage.Iterator) {
            storageIterator = base
        }

        public mutating func next() -> Element? {
            storageIterator.next().map(_castElement)
        }
    }

    @inlinable
    public func makeIterator() -> Iterator {
        .init(base: storage.makeIterator())
    }
}

extension Element.Attributes: Collection {
    @frozen
    public struct Index: Comparable {
        @usableFromInline
        let storageIndex: Storage.Index

        @usableFromInline
        init(base: Storage.Index) {
            storageIndex = base
        }

        @inlinable
        public static func <(lhs: Self, rhs: Self) -> Bool {
            lhs.storageIndex < rhs.storageIndex
        }
    }

    @inlinable
    public var startIndex: Index {
        .init(base: storage.startIndex)
    }

    @inlinable
    public var endIndex: Index {
        .init(base: storage.endIndex)
    }

    @inlinable
    public func index(after i: Index) -> Index {
        .init(base: storage.index(after: i.storageIndex))
    }

    @inlinable
    public subscript(position: Index) -> Element {
        Self._castElement(storage[position.storageIndex])
    }
}

extension Element.Attributes {
    @frozen
    public struct Keys: Collection, Equatable {
        public typealias Element = XMLElement.Attributes.Key
        public typealias Index = XMLElement.Attributes.Index

        @usableFromInline
        typealias Storage = XMLElement.Attributes.Storage.Keys

        @frozen
        public struct Iterator: IteratorProtocol {
            @usableFromInline
            var storageIterator: Storage.Iterator

            @usableFromInline
            init(base: Storage.Iterator) {
                storageIterator = base
            }

            @inlinable
            public mutating func next() -> Element? {
                storageIterator.next()
            }
        }

        @usableFromInline
        let storage: Storage

        @usableFromInline
        init(storage: Storage) {
            self.storage = storage
        }

        @inlinable
        public var startIndex: Index {
            .init(base: storage.startIndex)
        }

        @inlinable
        public var endIndex: Index {
            .init(base: storage.endIndex)
        }

        @inlinable
        public subscript(position: Index) -> Element {
            storage[position.storageIndex]
        }

        @inlinable
        public func makeIterator() -> Iterator {
            .init(base: storage.makeIterator())
        }

        @inlinable
        public func index(after i: Index) -> Index {
            .init(base: storage.index(after: i.storageIndex))
        }
    }

    @frozen
    public struct Contents: Collection, MutableCollection {
        public typealias Element = XMLElement.Attributes.Content
        public typealias Index = XMLElement.Attributes.Index

        @usableFromInline
        typealias Storage = XMLElement.Attributes.Storage.Values

        @frozen
        public struct Iterator: IteratorProtocol {
            @usableFromInline
            var storageIterator: Storage.Iterator

            @usableFromInline
            init(base: Storage.Iterator) {
                storageIterator = base
            }

            @inlinable
            public mutating func next() -> Element? {
                storageIterator.next()
            }
        }

        @usableFromInline
        var storage: Storage

        @usableFromInline
        init(storage: Storage) {
            self.storage = storage
        }

        @inlinable
        public var startIndex: Index {
            .init(base: storage.startIndex)
        }

        @inlinable
        public var endIndex: Index {
            .init(base: storage.endIndex)
        }

        @inlinable
        public subscript(position: Index) -> Element {
            get { storage[position.storageIndex] }
            set { storage[position.storageIndex] = newValue }
        }

        @inlinable
        public func makeIterator() -> Iterator {
            .init(base: storage.makeIterator())
        }

        @inlinable
        public func index(after i: Index) -> Index {
            .init(base: storage.index(after: i.storageIndex))
        }
    }
}

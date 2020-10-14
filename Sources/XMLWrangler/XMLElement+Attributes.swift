/// Describes a type that can turn itself into an `XMLElement.Attributes.Content`
public protocol XMLAttributeContentConvertible {
    /// The attribute content of this type.
    var xmlAttributeContent: XMLElement.Attributes.Content { get }
}

/// Describes a type that can be created from an `XMLElement.Attributes.Content` instance.
public protocol ExpressibleByXMLAttributeContent {
    /// Creates a new instance of the conforming type using the given attribute content.
    /// - Parameter xmlAttributeContent: The attribute content from which to create a new instance.
    init(xmlAttributeContent: XMLElement.Attributes.Content) throws
}

/// Describes a type that can be converted from and to an `XMLElement.Attributes.Content` instance.
public typealias XMLAttributeContentRepresentable = ExpressibleByXMLAttributeContent & XMLAttributeContentConvertible

extension String: XMLAttributeContentConvertible {
    /// inherited
    @inlinable
    public var xmlAttributeContent: XMLElement.Attributes.Content { .init(self) }
}

extension RawRepresentable where RawValue == XMLElement.Attributes.Content.RawValue, Self: XMLAttributeContentConvertible {
    /// inherited
    @inlinable
    public var xmlAttributeContent: XMLElement.Attributes.Content { .init(rawValue) }
}

extension XMLElement {
    /// Contains the attributes of an `XMLElement`.
    @frozen
    public struct Attributes: Equatable {
        /// Represents the key of an attribute.
        @frozen
        public struct Key: RawRepresentable, Hashable, Codable, ExpressibleByStringLiteral, XMLAttributeContentConvertible {
            /// inherited
            public typealias RawValue = String
            /// inherited
            public typealias StringLiteralType = RawValue

            /// inherited
            public let rawValue: RawValue

            /// inherited
            public init(rawValue: RawValue) { self.rawValue = rawValue }

            /// Creates a new key using the given raw value.
            @inlinable
            public init(_ rawValue: RawValue) { self.init(rawValue: rawValue) }

            /// inherited
            @inlinable
            public init(stringLiteral value: StringLiteralType) { self.init(rawValue: value) }
        }

        /// Represents the content of an attribute.
        @frozen
        public struct Content: RawRepresentable, Hashable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation, XMLAttributeContentConvertible {
            public typealias RawValue = String
            public typealias StringLiteralType = RawValue

            public let rawValue: RawValue

            @inlinable
            public var xmlAttributeValue: Content { self }

            public init(rawValue: RawValue) { self.rawValue = rawValue }

            /// Creates a new key using the given raw value.
            @inlinable
            public init(_ rawValue: RawValue) { self.init(rawValue: rawValue) }

            /// inherited
            @inlinable
            public init(stringLiteral value: StringLiteralType) { self.init(rawValue: value) }
        }

        @usableFromInline
        typealias Storage = Dictionary<Key, Content>

        @usableFromInline
        var storage: Storage

        /// Returns the keys of in this `Attributes`.
        @inlinable
        public var keys: Keys { .init(storage: storage.keys) }

        /// Returns the contents of in this `Attributes`. The `contents` can be mutated.
        @inlinable
        public var contents: Contents {
            get { .init(storage: storage.values) }
            set { storage.values = newValue.storage }
        }

        @usableFromInline
        init(storage: Storage) {
            self.storage = storage
        }

        /// Creates an empty attributes list.
        @inlinable
        public init() {
            self.init(storage: .init())
        }

        /// Creates an empty attributes list that reserves the given capacity.
        @inlinable
        public init(minimumCapacity: Int) {
            self.init(storage: .init(minimumCapacity: minimumCapacity))
        }

        /// Creates an attributes list with the given keys and contents.
        /// - Parameter keysAndContents: The sequence of unique key and content tuples to initialize from.
        /// - Precondition: The keys must be unique. Failure to fulfill this precondition will result in crahes.
        @inlinable
        public init<S>(uniqueKeysWithContents keysAndContents: S) where S: Sequence, S.Element == (Key, Content) {
            self.init(storage: .init(uniqueKeysWithValues: keysAndContents))
        }

        /// Creates an attributes list with the given keys and contents, using a closure for uniquing keys.
        /// - Parameters:
        ///   - keysAndContents: The sequence of key and content tuples to initialize from.
        ///   - combine: The closure to use for uniquing keys. The closure is passed the two contents for non-unique keys and should return the content to choose.
        /// - Throws: Rethrows errors thrown by `combine`.
        @inlinable
        public init<S>(_ keysAndContents: S, uniquingKeysWith combine: (Content, Content) throws -> Content) rethrows
        where S: Sequence, S.Element == (Key, Content)
        {
            try self.init(storage: .init(keysAndContents, uniquingKeysWith: combine))
        }

        /// Returns / sets the content for the given key.
        /// When setting nil, the content is removed for the given key.
        /// - Parameters key: The key to look up the content for.
        /// - Returns: The content for the given key. Nil if none is found.
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
        public mutating func removeContent(forKey key: Key) -> Content? {
            storage.removeValue(forKey: key)
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
    /// Initializes the dictionary using the storage of the given attributes.
    @inlinable
    public init(_ attributes: XMLElement.Attributes) {
        self = attributes.storage
    }
}

extension XMLElement.Attributes: ExpressibleByDictionaryLiteral {
    /// inherited
    @inlinable
    public init(dictionaryLiteral elements: (Key, XMLAttributeContentConvertible)...) {
        self.init(storage: .init(uniqueKeysWithValues: elements.lazy.map { ($0, $1.xmlAttributeContent) }))
    }
}

extension XMLElement.Attributes: Sequence {
    /// inherited
    public typealias Element = (key: Key, content: Content)

    /// Casts the `Element` tuple to `Storage.Element`. Uses `unsafeBitCast` since the tuples only differ in labels.
    @inlinable
    static func _castElement(_ storageElement: Storage.Element) -> Element {
        unsafeBitCast(storageElement, to: Element.self)
    }

    /// The iterator for iterating over attributes.
    @frozen
    public struct Iterator: IteratorProtocol {
        private var storageIterator: Storage.Iterator

        @usableFromInline
        init(base: Storage.Iterator) {
            storageIterator = base
        }

        /// inherited
        public mutating func next() -> Element? {
            storageIterator.next().map(_castElement)
        }
    }

    /// inherited
    @inlinable
    public func makeIterator() -> Iterator {
        .init(base: storage.makeIterator())
    }
}

extension XMLElement.Attributes: Collection {
    /// The index for attributes.
    @frozen
    public struct Index: Comparable {
        @usableFromInline
        let storageIndex: Storage.Index

        @usableFromInline
        init(base: Storage.Index) {
            storageIndex = base
        }

        /// inherited
        @inlinable
        public static func <(lhs: Self, rhs: Self) -> Bool {
            lhs.storageIndex < rhs.storageIndex
        }
    }

    /// inherited
    @inlinable
    public var startIndex: Index {
        .init(base: storage.startIndex)
    }

    /// inherited
    @inlinable
    public var endIndex: Index {
        .init(base: storage.endIndex)
    }

    /// inherited
    @inlinable
    public func index(after i: Index) -> Index {
        .init(base: storage.index(after: i.storageIndex))
    }

    /// inherited
    @inlinable
    public subscript(position: Index) -> Element {
        Self._castElement(storage[position.storageIndex])
    }
}

extension XMLElement.Attributes {
    /// A collection of keys inside `XMLElement.Attributes`
    @frozen
    public struct Keys: Collection, Equatable {
        /// inherited
        public typealias Element = XMLElement.Attributes.Key
        /// inherited
        public typealias Index = XMLElement.Attributes.Index

        @usableFromInline
        typealias Storage = XMLElement.Attributes.Storage.Keys

        /// The iterator for iterating over `XMLElement.Attributes.Keys`.
        @frozen
        public struct Iterator: IteratorProtocol {
            @usableFromInline
            var storageIterator: Storage.Iterator

            @usableFromInline
            init(base: Storage.Iterator) {
                storageIterator = base
            }

            /// inherited
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

        /// inherited
        @inlinable
        public var startIndex: Index {
            .init(base: storage.startIndex)
        }

        /// inherited
        @inlinable
        public var endIndex: Index {
            .init(base: storage.endIndex)
        }

        /// inherited
        @inlinable
        public subscript(position: Index) -> Element {
            storage[position.storageIndex]
        }

        /// inherited
        @inlinable
        public func makeIterator() -> Iterator {
            .init(base: storage.makeIterator())
        }

        /// inherited
        @inlinable
        public func index(after i: Index) -> Index {
            .init(base: storage.index(after: i.storageIndex))
        }
    }

    /// The (mutable) collection of contents for `XMLElement.Attributes`.
    @frozen
    public struct Contents: Collection, MutableCollection {
        /// inherited
        public typealias Element = XMLElement.Attributes.Content
        /// inherited
        public typealias Index = XMLElement.Attributes.Index

        @usableFromInline
        typealias Storage = XMLElement.Attributes.Storage.Values

        /// The iterator for iterating over `XMLElement.Attributes.Contents`.
        @frozen
        public struct Iterator: IteratorProtocol {
            @usableFromInline
            var storageIterator: Storage.Iterator

            @usableFromInline
            init(base: Storage.Iterator) {
                storageIterator = base
            }

            /// inherited
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

        /// inherited
        @inlinable
        public var startIndex: Index {
            .init(base: storage.startIndex)
        }

        /// inherited
        @inlinable
        public var endIndex: Index {
            .init(base: storage.endIndex)
        }

        /// inherited
        @inlinable
        public subscript(position: Index) -> Element {
            get { storage[position.storageIndex] }
            set { storage[position.storageIndex] = newValue }
        }

        /// inherited
        @inlinable
        public func makeIterator() -> Iterator {
            .init(base: storage.makeIterator())
        }

        /// inherited
        @inlinable
        public func index(after i: Index) -> Index {
            .init(base: storage.index(after: i.storageIndex))
        }
    }
}

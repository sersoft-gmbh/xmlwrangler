/// Describes a type that can turn itself into an ``XMLElement/Attributes/Content``
public protocol XMLAttributeContentConvertible {
    /// The attribute content of this type.
    var xmlAttributeContent: XMLElement.Attributes.Content { get }
}

/// Describes a type that can be created from an ``XMLElement/Attributes/Content`` instance.
public protocol ExpressibleByXMLAttributeContent {
    /// Creates a new instance of the conforming type using the given attribute content.
    /// - Parameter xmlAttributeContent: The attribute content from which to create a new instance.
    init?(xmlAttributeContent: XMLElement.Attributes.Content)
}

/// Describes a type that can be converted from and to an ``XMLElement/Attributes/Content`` instance.
public typealias XMLAttributeContentRepresentable = ExpressibleByXMLAttributeContent & XMLAttributeContentConvertible

extension String: XMLAttributeContentRepresentable {
    @inlinable
    public var xmlAttributeContent: XMLElement.Attributes.Content { .init(self) }

    @inlinable
    public init(xmlAttributeContent: XMLElement.Attributes.Content) {
        self = xmlAttributeContent.rawValue
    }
}

extension XMLAttributeContentConvertible where Self: RawRepresentable, RawValue == XMLElement.Attributes.Content.RawValue {
    @inlinable
    public var xmlAttributeContent: XMLElement.Attributes.Content { .init(rawValue) }
}

extension ExpressibleByXMLAttributeContent where Self: RawRepresentable, Self.RawValue: LosslessStringConvertible {
    @inlinable
    public init?(xmlAttributeContent: XMLElement.Attributes.Content) {
        self.init(rawValueDescription: xmlAttributeContent.rawValue)
    }
}

extension ExpressibleByXMLAttributeContent where Self: LosslessStringConvertible {
    @inlinable
    public init?(xmlAttributeContent: XMLElement.Attributes.Content) {
        self.init(xmlAttributeContent.rawValue)
    }
}

extension ExpressibleByXMLAttributeContent where Self: LosslessStringConvertible, Self: RawRepresentable, Self.RawValue: LosslessStringConvertible {
    @inlinable
    public init?(xmlAttributeContent: XMLElement.Attributes.Content) {
        self.init(rawValueDescription: xmlAttributeContent.rawValue)
    }
}

extension XMLElement {
    /// Contains the attributes of an ``XMLElement``.
    @frozen
    public struct Attributes: Sendable, Equatable {
        /// Represents the key of an attribute.
        @frozen
        public struct Key: RawRepresentable,
                           Sendable,
                           Hashable,
                           Codable,
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

            /// Creates a new key using the given raw value.
            @inlinable
            public init(_ rawValue: RawValue) { self.init(rawValue: rawValue) }

            @inlinable
            public init(stringLiteral value: StringLiteralType) { self.init(rawValue: value) }
        }

        /// Represents the content of an attribute.
        @frozen
        public struct Content: RawRepresentable,
                               Sendable,
                               Hashable,
                               ExpressibleByStringLiteral,
                               ExpressibleByStringInterpolation,
                               XMLAttributeContentRepresentable,
                               CustomStringConvertible,
                               CustomDebugStringConvertible
        {
            public typealias RawValue = String
            public typealias StringLiteralType = RawValue

            public let rawValue: RawValue

            @inlinable
            public var description: String { rawValue }
            public var debugDescription: String { "\(Self.self)(\(rawValue))" }

            @inlinable
            public var xmlAttributeContent: Content { self }

            public init(rawValue: RawValue) { self.rawValue = rawValue }

            /// Creates a new key using the given raw value.
            @inlinable
            public init(_ rawValue: RawValue) { self.init(rawValue: rawValue) }

            @inlinable
            public init(stringLiteral value: StringLiteralType) { self.init(rawValue: value) }

            @inlinable
            public init(xmlAttributeContent: Content) { self = xmlAttributeContent }
        }

        @usableFromInline
        typealias Storage = Dictionary<Key, Content>

        @usableFromInline
        var storage: Storage

        /// Returns the keys of in this ``XMLElement/Attributes``.
        @inlinable
        public var keys: Keys { .init(storage: storage.keys) }

        /// Returns the contents of in this ``XMLElement/Attributes``. The  ``XMLElement/Attributes/contents`` can be mutated.
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
        /// - Returns: The content for the given key. `nil` if none is found.
        @inlinable
        public subscript(key: Key) -> Content? {
            get { storage[key] }
            set { storage[key] = newValue }
        }

        /// Returns / sets the content for the given key, using a default if the key does not exist.
        /// - Parameters:
        ///   - key: The key to look up the content for.
        ///   - default: The default value to use if no value exists for the given `key`.
        /// - Returns: The content for the given key. `default` if none is found.
        @inlinable
        public subscript<Default: XMLAttributeContentConvertible>(key: Key, default defaultValue: @autoclosure () -> Default) -> Content {
            get { storage[key, default: defaultValue().xmlAttributeContent] }
            set { storage[key, default: defaultValue().xmlAttributeContent] = newValue }
        }

        /// Filters the attributes  using the given predicate closure.
        /// - Parameter isIncluded: The closure to execute for each element.
        ///                         Should return `true` for elements that should be in the resulting attributes.
        /// - Throws: Any error thrown by `isIncluded`.
        /// - Returns: The filtered attributes. Only elements for which `isIncluded` returned `true` are contained.
        @inlinable
        public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self {
            try .init(storage: storage.filter { try isIncluded((key: $0.key, content: $0.value)) })
        }

        /// Updates the content element for a given key.
        /// - Parameters:
        ///   - content: The new content element to store for `key`.
        ///   - key: The key for which to update the content element.
        /// - Returns: The old element of `key`, if there was one. `nil` otherwise.
        @inlinable
        @discardableResult
        public mutating func updateContent(_ content: Content, forKey key: Key) -> Content? {
            storage.updateValue(content, forKey: key)
        }

        /// Removes the content for a given key.
        /// - Parameter key: The key for which to remove the content.
        /// - Returns: The old values of `key`, if there was one. `nil` otherwise.
        @inlinable
        @discardableResult
        public mutating func removeContent(forKey key: Key) -> Content? {
            storage.removeValue(forKey: key)
        }

        /// Merges another sequence of key-content-pairs into the receiving attributes.
        /// - Parameters:
        ///   - other: The sequence of key-content-pairs to merge.
        ///   - combine: The closure to use for uniquing keys. Called for each key-conflict with both contents.
        ///              The returned element is used, the other one discarded.
        /// - Throws: Any error thrown by `combine`.
        @inlinable
        public mutating func merge<S>(_ other: S, uniquingKeysWith combine: (Content, Content) throws -> Content) rethrows
        where S: Sequence, S.Element == (Key, Content)
        {
            try storage.merge(other, uniquingKeysWith: combine)
        }

        /// Merges another attributes list into the receiving attributes.
        /// - Parameters:
        ///   - other: The other attributes list to merge.
        ///   - combine: The closure to use for uniquing keys. Called for each key-conflict with both contents.
        ///              The returned element is used, the other one discarded.
        /// - Throws: Any error thrown by `combine`.
        @inlinable
        public mutating func merge(_ other: Self, uniquingKeysWith combine: (Content, Content) throws -> Content) rethrows {
            try storage.merge(other.storage, uniquingKeysWith: combine)
        }

        /// Returns the result of merging another sequence of key-content-pairs with the receiving attributes.
        /// - Parameters:
        ///   - other: The sequence of key-content-pairs to merge.
        ///   - combine: The closure to use for uniquing keys. Called for each key-conflict with both contents.
        ///              The returned element is used, the other one discarded.
        /// - Throws: Any error thrown by `combine`.
        /// - Returns: The merged attributes list.
        @inlinable
        public func merging<S>(_ other: S, uniquingKeysWith combine: (Content, Content) throws -> Content) rethrows -> Self
        where S: Sequence, S.Element == (Key, Content)
        {
            try .init(storage: storage.merging(other, uniquingKeysWith: combine))
        }

        /// Returns the result of merging another attributes list into the receiving attributes.
        /// - Parameters:
        ///   - other: The other attributes list to merge.
        ///   - combine: The closure to use for uniquing keys. Called for each key-conflict with both contents.
        ///              The returned element is used, the other one discarded.
        /// - Throws: Any error thrown by `combine`.
        /// - Returns: The merged attributes list.
        @inlinable
        public func merging(_ other: Self, uniquingKeysWith combine: (Content, Content) throws -> Content) rethrows -> Self {
            try .init(storage: storage.merging(other.storage, uniquingKeysWith: combine))
        }

        /// Removes all key-content pairs from the attributes.
        /// Calling this method invalidates all indices of the attributes.
        /// - Parameter keepCapacity: Whether the attributes should keep its underlying storage capacity. Defaults to `false`.
        @inlinable
        public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
            storage.removeAll(keepingCapacity: keepCapacity)
        }
    }
}

extension Dictionary where Key == XMLElement.Attributes.Key, Value == XMLElement.Attributes.Content {
    /// Initializes the dictionary using the storage of the given attributes.
    /// - Parameter attributes: The ``XMLElement/Attributes`` whose contents should be contained in the dictionary.
    @inlinable
    public init(elementsOf attributes: XMLElement.Attributes) {
        self = attributes.storage
    }
}

extension XMLElement.Attributes: ExpressibleByDictionaryLiteral {
    @inlinable
    public init(dictionaryLiteral elements: (Key, XMLAttributeContentConvertible)...) {
        self.init(storage: .init(uniqueKeysWithValues: elements.lazy.map { ($0, $1.xmlAttributeContent) }))
    }
}

extension XMLElement.Attributes: Sequence {
    public typealias Element = (key: Key, content: Content)

    /// Casts the ``XMLElement/Attributes/Element`` tuple to ``XMLElement/Attributes/Storage/Element``.
    /// - Note: Uses `unsafeBitCast` since the tuples only differ in labels.
    @usableFromInline
    static func _castElement(_ storageElement: Storage.Element) -> Element {
        unsafeBitCast(storageElement, to: Element.self)
    }

    /// The iterator for iterating over attributes.
    @frozen
    public struct Iterator: IteratorProtocol, Sendable {
        @usableFromInline
        var storageIterator: Storage.Iterator

        @usableFromInline
        init(base: Storage.Iterator) {
            storageIterator = base
        }

        @inlinable
        public mutating func next() -> Element? {
            storageIterator.next().map(_castElement)
        }
    }

    @inlinable
    public var underestimatedCount: Int { storage.underestimatedCount }

    @inlinable
    public func makeIterator() -> Iterator {
        .init(base: storage.makeIterator())
    }
}

extension XMLElement.Attributes: Collection {
    /// The index for attributes.
    @frozen
    public struct Index: Comparable, Sendable {
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
    public var isEmpty: Bool { storage.isEmpty }

    @inlinable
    public var count: Int { storage.count }

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

extension XMLElement.Attributes: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        """
        \(Self.self) [\(storage.count) key/content pair(s)] {
        \(storage.map { "    \($0.key): \($0.value)" }.joined(separator: "\n"))
        }
        """
    }

    public var debugDescription: String {
        """
        \(Self.self) [\(storage.count) key/content pair(s)] {
        \(storage.map { "    \($0.key): \($0.value.debugDescription)" }.joined(separator: "\n"))
        }
        """
    }
}

extension XMLElement.Attributes {
    /// A collection of keys inside ``XMLElement/Attributes``
    @frozen
    public struct Keys: Collection, Sendable, Equatable, CustomStringConvertible, CustomDebugStringConvertible {
        public typealias Element = XMLElement.Attributes.Key
        public typealias Index = XMLElement.Attributes.Index

        @usableFromInline
        typealias Storage = XMLElement.Attributes.Storage.Keys

        /// The iterator for iterating over ``XMLElement/Attributes/Keys``.
        @frozen
        public struct Iterator: IteratorProtocol, Sendable {
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

        public var description: String { Array(storage).description }
        public var debugDescription: String { Array(storage).debugDescription }

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

    /// The (mutable) collection of contents for ``XMLElement/Attributes``.
    @frozen
    public struct Contents: Collection, MutableCollection, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
        public typealias Element = XMLElement.Attributes.Content
        public typealias Index = XMLElement.Attributes.Index

        @usableFromInline
        typealias Storage = XMLElement.Attributes.Storage.Values

        /// The iterator for iterating over ``XMLElement/Attributes/Contents``.
        @frozen
        public struct Iterator: IteratorProtocol, Sendable {
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

        public var description: String { Array(storage).description }
        public var debugDescription: String { Array(storage).debugDescription }

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

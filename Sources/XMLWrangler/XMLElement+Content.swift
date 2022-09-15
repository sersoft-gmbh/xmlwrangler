extension XMLElement {
    /// A collection implementation that represents the contents of an XML element.
    @frozen
    public struct Content: Equatable {
        @usableFromInline
        typealias Storage = Array<Element>

        /// Describes an part (element) of the `XMLElement`'s content.
        public enum Element: Equatable,
                             ExpressibleByStringLiteral,
                             ExpressibleByStringInterpolation,
                             ExpressibleByXMLElement,
                             CustomStringConvertible,
                             CustomDebugStringConvertible
        {
            /// The type used to represent a string content.
            public typealias StringPart = String
            /// inherited
            public typealias StringLiteralType = StringPart

            /// Represents a raw string part.
            case string(StringPart)
            /// Represents an xml element part.
            case element(XMLElement)

            // TODO: Do we need a CDATA case, too? -> For now we serialize these into Strings

            /// inherited
            public var description: String {
                switch self {
                case .string(let str): return "StringPart(\(str))"
                case .element(let element): return "Element(\(element.name))"
                }
            }

            /// inherited
            public var debugDescription: String {
                switch self {
                case .string(let str): return "StringPart { \(str) }"
                case .element(let element): return "Element {\n\(element.debugDescription)\n}"
                }
            }

            /// inherited
            @inlinable
            public init(stringLiteral value: StringLiteralType) {
                self = .string(value)
            }

            /// inherited
            @inlinable
            public init(xml: XMLElement) {
                self = .element(xml)
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
        public init() {
            self.init(storage: .init())
        }
    }
}

extension XMLElement.Content: CustomStringConvertible, CustomDebugStringConvertible {
    /// inherited
    @inlinable
    public var description: String { storage.description }

    /// inherited
    @inlinable
    public var debugDescription: String { storage.debugDescription }
}

extension XMLElement.Content: Sequence, Collection, MutableCollection {
    /// inherited
    public typealias Index = Int
    /// inherited
    public typealias Indices = DefaultIndices<Self>
    /// inherited
    public typealias SubSequence = Slice<Self>

    /// inherited
    @inlinable
    public var startIndex: Index { storage.startIndex }

    /// inherited
    @inlinable
    public var endIndex: Index { storage.endIndex }

    /// inherited
    @inlinable
    public var isEmpty: Bool { storage.isEmpty }

    /// inherited
    @inlinable
    public var underestimatedCount: Int { storage.underestimatedCount }

    /// inherited
    @inlinable
    public var count: Int { storage.count }

    /// inherited
    @inlinable
    public subscript(position: Index) -> Element {
        get { storage[position] }
        set { storage[position] = newValue }
    }

    /// inherited
    @inlinable
    public func index(after i: Index) -> Index {
        storage.index(after: i)
    }
}

extension XMLElement.Content: BidirectionalCollection {
    /// inherited
    @inlinable
    public func index(before i: Index) -> Index {
        storage.index(before: i)
    }
}

extension XMLElement.Content: RandomAccessCollection {
    /// inherited
    @inlinable
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        storage.index(i, offsetBy: distance)
    }

    /// inherited
    @inlinable
    public func distance(from start: Index, to end: Index) -> Int {
        storage.distance(from: start, to: end)
    }
}

extension XMLElement.Content: RangeReplaceableCollection {
    /// inherited
    @inlinable
    public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C)
    where C: Collection, Element == C.Element
    {
        storage.replaceSubrange(subrange, with: newElements)
    }
}

extension XMLElement.Content: ExpressibleByArrayLiteral {
    /// inherited
    public typealias ArrayLiteralElement = Element

    /// inherited
    @inlinable
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(storage: elements)
    }
}

extension XMLElement.Content: ExpressibleByXMLElement {
    /// inherited
    @inlinable
    public init(xml: XMLElement) {
        self.init(storage: [.element(xml)])
    }
}

extension XMLElement.Content: ExpressibleByStringLiteral {
    /// inherited
    public typealias StringLiteralType = Element.StringLiteralType

    /// inherited
    @inlinable
    public init(stringLiteral value: StringLiteralType) {
        self.init(storage: [.init(stringLiteral: value)])
    }
}

extension XMLElement.Content: ExpressibleByStringInterpolation {
    /// The string interpolation type for `Element.Content`.
    @frozen
    public struct StringInterpolation: StringInterpolationProtocol {
        /// inherited
        public typealias StringLiteralType = XMLElement.Content.StringLiteralType

        @usableFromInline
        var storage: Storage = []

        /// inherited
        public init(literalCapacity: Int, interpolationCount: Int) {
            storage.reserveCapacity(interpolationCount + Swift.min(literalCapacity, 2))
        }

        @usableFromInline
        mutating func _appendString<S: StringProtocol>(_ string: S) {
            guard !string.isEmpty else { return }
            if case .string(let str) = storage.last {
                storage[storage.indexBeforeEndIndex] = .string(str + string)
            } else {
                storage.append(.string(String(string)))
            }
        }

        @usableFromInline
        mutating func _appendContent(_ content: XMLElement.Content) {
            guard !content.storage.isEmpty else { return }
            let compressed = content.compressed().storage
            if case .string(let addendum) = compressed.first, case .string(let str) = storage.last {
                storage[storage.indexBeforeEndIndex] = .string(str + addendum)
                storage.append(contentsOf: compressed.dropFirst())
            } else {
                storage.append(contentsOf: compressed)
            }
        }

        /// Appends a literal to the contents by simply adding a `.string` element with the literal's contents.
        /// - Parameter literal: The literal to append.
        @inlinable
        public mutating func appendLiteral(_ literal: StringLiteralType) {
            _appendString(literal)
        }

        /// Appends a string element to the contents.
        /// - Parameter string: The string to append.
        @inlinable
        public mutating func appendInterpolation<S: StringProtocol>(_ string: S) {
            _appendString(string)
        }

//        @inlinable
//        public mutating func appendInterpolation<B: BinaryInteger>(_ int: B) {
//            _appendString(String(int))
//        }

        /// Appends the `XMLElement` of a `XMLElementConvertible` type to the contents.
        /// - Parameter convertible: The convertible whose `xml` to append to the contents.
        @inlinable
        public mutating func appendInterpolation<Convertible>(_ convertible: Convertible)
        where Convertible: XMLElementConvertible
        {
            storage.append(.element(convertible.xml))
        }

        /// Appends the contents of another sequence of `XMLElement.Content.Element` to the contents.
        /// - Parameter contents: The sequence to append.
        @inlinable
        public mutating func appendInterpolation<C: Sequence>(_ contents: C)
        where C.Element == XMLElement.Content.Element
        {
            _appendContent(.init(contents))
        }

        /// Appends a variadic list of `XMLElement.Content.Element` to the contents.
        /// - Parameter contents: The variadic list of `XMLElement.Content` to append.
        @inlinable
        public mutating func appendInterpolation(_ contents: XMLElement.Content.Element...) {
            _appendContent(.init(storage: contents))
        }

        /// Appends another `XMLElement.Content` instance.
        /// - Parameter content: The `XMLElement.Content` whose contents to append.
        @inlinable
        public mutating func appendInterpolation(_ content: XMLElement.Content) {
            _appendContent(content)
        }

        /// Appends the contents of another `XMLElement`.
        /// - Parameter element: The `XMLElement` whose `content` to append.
        /// - Note: This only appends the `content` of `element`, **not** the `element` itself!
        @inlinable
        public mutating func appendInterpolation(contentOf element: XMLElement) {
            _appendContent(element.content)
        }
    }

    /// inherited
    @inlinable
    public init(stringInterpolation: StringInterpolation) {
        self.init(storage: stringInterpolation.storage)
    }
}

#if compiler(>=5.5) && canImport(_Concurrency)
extension XMLElement.Content: Sendable {}
extension XMLElement.Content.Element: Sendable {}
extension XMLElement.Content.Iterator: Sendable {}
extension XMLElement.Content.StringInterpolation: Sendable {}
#endif

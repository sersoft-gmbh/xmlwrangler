extension Element {
    /// A collection implementation that represents the content of an XML element.
    @frozen
    public struct Content: Equatable, Collection {
        /// inherited
        public typealias Index = Int
        /// inherited
        public typealias Indices = DefaultIndices<Self>
        /// inherited
        public typealias SubSequence = Slice<Self>

        @usableFromInline
        typealias Storage = [Element]

        /// Describes an part (element) of the `XMLElement`'s content.
        public enum Element: Equatable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation, ExpressibleByXMLElement {
            /// The type used to represent a string content
            public typealias StringPart = String
            /// inherited
            public typealias StringLiteralType = StringPart

            /// A raw string
            case string(StringPart)
            /// An xml object
            case object(XMLElement)

            // TODO: Do we need a CDATA case, too? -> For now we serialize these into Strings

            /// inherited
            @inlinable
            public init(stringLiteral value: StringLiteralType) {
                self = .string(value)
            }

            /// inherited
            @inlinable
            public init(xml: XMLElement) {
                self = .object(xml)
            }
        }

        @usableFromInline
        var storage: Storage

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

        @usableFromInline
        init(storage: Storage) {
            self.storage = storage
        }

        /// inherited
        @inlinable
        public init() {
            self.init(storage: [])
        }

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
}

extension Element.Content: BidirectionalCollection {
    /// inherited
    @inlinable
    public func index(before i: Index) -> Index {
        storage.index(before: i)
    }
}

extension Element.Content: RandomAccessCollection {
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

extension Element.Content: RangeReplaceableCollection {
    /// inherited
    @inlinable
    public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C) where C : Collection, Element == C.Element {
        storage.replaceSubrange(subrange, with: newElements)
    }
}

extension Element.Content: MutableCollection {}

extension Element.Content: ExpressibleByArrayLiteral {
    /// inherited
    public typealias ArrayLiteralElement = Element

    /// inherited
    @inlinable
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(storage: elements)
    }
}

extension Element.Content: ExpressibleByXMLElement {
    /// inherited
    @inlinable
    public init(xml: XMLElement) {
        self.init(storage: [.object(xml)])
    }
}

extension Element.Content: ExpressibleByStringLiteral {
    /// inherited
    public typealias StringLiteralType = Element.StringLiteralType

    /// inherited
    @inlinable
    public init(stringLiteral value: StringLiteralType) {
        self.init(storage: [.init(stringLiteral: value)])
    }
}

extension Element.Content: ExpressibleByStringInterpolation {
    /// The interpolation type for `Element.Content`.
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

        /// inherited
        @inlinable
        public mutating func appendLiteral(_ literal: StringLiteralType) {
            storage.append(.init(stringLiteral: literal))
        }

        /// inherited
        @inlinable
        public mutating func appendInterpolation<S: StringProtocol>(_ string: S) {
            storage.append(.string(String(string)))
        }

//        @inlinable
//        public mutating func appendInterpolation<B: BinaryInteger>(_ int: B) {
//            storage.append(.string(String(int)))
//        }

        /// inherited
        @inlinable
        public mutating func appendInterpolation(_ element: XMLElement) {
            storage.append(.object(element))
        }

        /// inherited
        @inlinable
        public mutating func appendInterpolation<C: Collection>(_ content: C) where C.Element == XMLElement.Content.Element {
            storage.append(contentsOf: content)
        }

        /// inherited
        @inlinable
        public mutating func appendInterpolation(_ content: XMLElement.Content) {
            appendInterpolation(content.storage)
        }

        /// inherited
        @inlinable
        public mutating func appendInterpolation(contentOf element: XMLElement) {
            appendInterpolation(element.content.storage)
        }
    }

    /// inherited
    @inlinable
    public init(stringInterpolation: StringInterpolation) {
        self.init(storage: stringInterpolation.storage)
    }
}

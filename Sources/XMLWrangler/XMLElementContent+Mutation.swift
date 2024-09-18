extension XMLElement.Content {
    // @usableFromInline -> added with indention support.
    mutating func _appendString(_ string: some StringProtocol) {
        if !storage.isEmpty,
           case let lastIndex = storage.index(endIndex, offsetBy: -1),
           case .string(let str) = storage[lastIndex] {
            storage[lastIndex] = .string(str + string)
        } else {
            storage.append(.string(String(string)))
        }
    }

    /// Appends either a new ``XMLElement/Content/Element/string(_:)`` element,
    /// or if the last one is already ``XMLElement/Content/Element/string(_:)``, appends `string` to the last one.
    /// - Parameter string: The string to append.
    // @inlinable -> added with indention support.
    public mutating func appendString(_ string: Element.StringPart) {
        _appendString(string)
    }

    /// Appends an element wrapped as ``XMLElement/Content/Element/element(_:)``.
    /// - Parameter element: The element to append wrapped in ``XMLElement/Content/Element/element(_:)``.
    @inlinable
    public mutating func appendElement(_ element: XMLElement) {
        storage.append(.element(element))
    }

    /// Appends the xml element of a convertible type.
    /// - Parameter convertible: The type conforming to ``XMLElementConvertible``.
    @inlinable
    public mutating func append(elementOf convertible: some XMLElementConvertible) {
        appendElement(convertible.xml)
    }

    /// Appends the contents of a sequcence of elements wrapped as ``XMLElement/Content/Element/element(_:)``.
    /// - Parameter elements: The sequence of elements to append wrapped in ``XMLElement/Content/Element/element(_:)``.
    @inlinable
    public mutating func append(contentsOf elements: some Sequence<XMLElement>) {
        storage.append(contentsOf: elements.lazy.map { .element($0) })
    }

    /// Appends the one or more elements wrapped as ``XMLElement/Content/Element/element(_:)``.
    /// - Parameter elements: The elements to append wrapped in ``XMLElement/Content/Element/element(_:)``.
    @inlinable
    public mutating func appendElements(_ elements: XMLElement...) {
        append(contentsOf: elements)
    }

    @usableFromInline
    mutating func _compress(stringSeparator: Character?) {
        var currentIndex = storage.startIndex
        while let nextIndex = storage.index(currentIndex, offsetBy: 1, limitedBy: storage.endIndex) {
            defer { currentIndex = nextIndex }
            guard case .string(var newStr) = storage[currentIndex] else { continue }
            while nextIndex < storage.endIndex, case .string(let nextStr) = storage[nextIndex] {
                if let stringSeparator {
                    newStr.append(stringSeparator)
                }
                newStr += nextStr
                storage.remove(at: nextIndex) // TODO: this might be a performance problem
            }
            storage[currentIndex] = .string(newStr)
        }
    }

    @usableFromInline
    func _compressed(stringSeparator: Character?) -> Self {
        var compressed = self
        compressed._compress(stringSeparator: stringSeparator)
        return compressed
    }

    /// Merges consecutive ``XMLElement/Content/Element/string(_:)`` elements into one.
    /// - SeeAlso: ``XMLElement/Content/compressed()``
    @inlinable
    public mutating func compress() {
        _compress(stringSeparator: nil)
    }

    /// Returns a compressed version of `self`, where all consecutive ``XMLElement/Content/Element/string(_:)`` elements were merged into one.
    /// - Returns: A compressed version of `self`.
    /// - SeeAlso: ``XMLElement/Content/compress()``
    @inlinable
    public func compressed() -> Self {
        _compressed(stringSeparator: nil)
    }
}

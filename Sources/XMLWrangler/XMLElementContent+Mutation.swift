extension XMLElement.Content {
    /// Appends either a new `.string` element, or if the last one is already `.string`, appends `string` to the last one.
    /// - Parameter string: The string to append.
    public mutating func append(string: Element.StringPart) {
        if !storage.isEmpty,
           case let lastIndex = storage.index(endIndex, offsetBy: -1),
           case .string(let str) = storage[lastIndex] {
            storage[lastIndex] = .string(str + string)
        } else {
            storage.append(.string(string))
        }
    }

    /// Appends an element wrapped as `.element`.
    /// - Parameter element: The element to append wrapped in `.element`.
    @inlinable
    public mutating func append(element: XMLElement) {
        storage.append(.element(element))
    }

    /// Appends the xml element of a convertible type.
    /// - Parameter convertible: The type conforming to `XMLElementConvertible`.
    @inlinable
    public mutating func append<Convertible: XMLElementConvertible>(elementOf convertible: Convertible) {
        append(element: convertible.xml)
    }

    /// Appends the contents of a sequcence of elements wrapped as `.element`.
    /// - Parameter elements: The sequence of elements to append wrapped in `.element`.
    @inlinable
    public mutating func append<S: Sequence>(contentsOf elements: S) where S.Element == XMLElement {
        storage.append(contentsOf: elements.lazy.map { .element($0) })
    }

    /// Appends the one or more elements wrapped as `.element`.
    /// - Parameter elements: The elements to append wrapped in `.element`.
    @inlinable
    public mutating func append(elements: XMLElement...) {
        append(contentsOf: elements)
    }

//    /// Appends the xml element of a convertible type.
//    /// - Parameter convertible: The type conforming to `XMLElementConvertible`.
//    @inlinable
//    public mutating func append<Convertible: XMLElementConvertible>(elementOf convertible: Convertible) {
//        append(element: convertible.xml)
//    }

    /// Merges consecutive `.string` elements into one.
    public mutating func compress() {
        var currentIndex = storage.startIndex
        while let nextIndex = storage.index(currentIndex, offsetBy: 1, limitedBy: storage.endIndex) {
            defer { currentIndex = nextIndex }
            guard case .string(var newStr) = storage[currentIndex] else { continue }
            while nextIndex < storage.endIndex, case .string(let nextStr) = storage[nextIndex] {
                newStr += nextStr
                storage.remove(at: nextIndex) // TODO: this might be a performance problem
            }
            storage[currentIndex] = .string(newStr)
        }
    }

    /// Returns a compressed version of `self`, where all consecutive `.string` elements were merged into one.
    /// - Returns: A compressed version of `self`.
    /// - SeeAlso: `compress()`
    public func compressed() -> Self {
        var compressed = self
        compressed.compress()
        return compressed
    }
}

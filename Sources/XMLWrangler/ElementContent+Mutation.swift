extension XMLElement.Content {
    /// Appends either a new `.string` element, or if the last one is already `.string`, appends `string` to the last one.
    /// - Parameter string: The string to append.
    public mutating func append(string: String) {
        if !storage.isEmpty,
           case let lastIndex = storage.index(endIndex, offsetBy: -1),
           case .string(let str) = storage[lastIndex] {
            storage[lastIndex] = .string(str + string)
        } else {
            storage.append(.string(string))
        }
    }

    /// Appends an element wrapped as `.object`.
    /// - Parameter object: The element to append wrapped in `.object`.
    @inlinable
    public mutating func append(object: XMLElement) {
        storage.append(.object(object))
    }

    /// Appends the xml element of a convertible object.
    /// - Parameter convertible: The object conforming to `XMLElementConvertible`.
    @inlinable
    public mutating func append<Convertible: XMLElementConvertible>(objectOf convertible: Convertible) {
        append(object: convertible.xml)
    }

    /// Appends the contents of a sequcence of elements wrapped as `.object`.
    /// - Parameter objects: The sequence of elements to append wrapped in `.object`.
    @inlinable
    public mutating func append<S: Sequence>(contentsOf objects: S) where S.Element == XMLElement {
        storage.append(contentsOf: objects.lazy.map { .object($0) })
    }

    /// Appends the one or more elements wrapped as `.object`.
    /// - Parameter objects: The elements to append wrapped in `.object`.
    @inlinable
    public mutating func append(objects: XMLElement...) {
        append(contentsOf: objects)
    }

//    /// Appends the xml element of a convertible object.
//    /// - Parameter convertible: The object conforming to `XMLElementConvertible`.
//    @inlinable
//    public mutating func append<Convertible: XMLElementConvertible>(objectOf convertible: Convertible) {
//        append(object: convertible.xml)
//    }

    /// Merges consecutive `.string` objects into one.
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

    /// Returns a compressed version of `self`, where all consecutive `.string` objects were merged into one.
    /// - Returns: A compressed version of `self`.
    /// - SeeAlso: `compress()`
    public func compressed() -> Self {
        var compressed = self
        compressed.compress()
        return compressed
    }
}

extension XMLElement {
    /// Appends a string to the content.
    /// - Parameter string: The string to append to the content.
    /// - SeeAlso: ``XMLElement/Content/appendString(_:)``
    @inlinable
    public mutating func appendString(_ string: Content.Element.StringPart) {
        content.appendString(string)
    }

    /// Appends an element to the content.
    /// - Parameter element: The element to append to the content.
    /// - SeeAlso: ``XMLElement/Content/appendElement(_:)``
    @inlinable
    public mutating func appendElement(_ element: XMLElement) {
        content.appendElement(element)
    }

    /// Appends the xml element of a convertible type.
    /// - Parameter convertible: The type conforming to ``XMLElementConvertible``.
    /// - SeeAlso: ``XMLElement/Content/append(elementOf:)``
    @inlinable
    public mutating func append(elementOf convertible: some XMLElementConvertible) {
        content.append(elementOf: convertible)
    }

    /// Appends the contents of a sequence of elements to the content.
    /// - Parameter elements: The sequence of elements to append to the content.
    /// - SeeAlso: ``XMLElement/Content/append(contentsOf:)``
    @inlinable
    public mutating func append(contentsOf elements: some Sequence<XMLElement>) {
        content.append(contentsOf: elements)
    }

    /// Appends one or more elements to the content.
    /// - Parameter elements: The elements to append to the content.
    /// - SeeAlso: ``XMLElement/Content/appendElements(_:)``
    @inlinable
    public mutating func appendElements(_ elements: XMLElement...) {
        append(contentsOf: elements)
    }
}

extension XMLElement {
    /// Gives mutating access to an element at a given path.
    /// - Parameters:
    ///   - path: A collection of element names which represent the path to the element to mutate.
    ///   - work: The closure which is provided with mutating access to the element at the given path.
    /// - Returns: The value returned by `work`.
    /// - Throws: ``XMLElement/LookupError/missingChild(element:childName:)`` in case the path contains an inexistent element at some point. Or any error thrown by `work`
    public mutating func withMutatingAccess<T>(toElementAt path: some Collection<Name>,
                                               do work: (inout XMLElement) throws -> T) throws -> T {
        guard !path.isEmpty else { return try work(&self) }
        guard let index = content.firstIndex(where: { $0.element?.name == path[path.startIndex] }),
              var element = content[index].element // This one should always succeed.
        else { throw LookupError.missingChild(element: self, childName: path[path.startIndex]) }
        defer { content[index] = .element(element) }
        return try element.withMutatingAccess(toElementAt: path.dropFirst(), do: work)
    }

    /// Gives mutating access to an element at a given path.
    /// - Parameters:
    ///   - path: A list of element names which represent the path to the element to mutate.
    ///   - work: The closure which is provided with mutating access to the element at the given path.
    /// - Returns: The value returned by `work`.
    /// - Throws: ``XMLElement/LookupError/missingChild(element:childName:)`` in case the path contains an inexistent element at some point. Or any error thrown by `work`
    @inlinable
    public mutating func withMutatingAccess<T>(toElementAt path: Name..., do work: (inout XMLElement) throws -> T) throws -> T {
        try withMutatingAccess(toElementAt: path, do: work)
    }

    /// Replaces an element at a given path with a new element.
    /// - Parameters:
    ///   - path: A collection of element names which represent the path to the element to replace.
    ///   - newElement: The element insert in place of the element at `path`.
    /// - Throws: ``XMLElement/LookupError/missingChild(element:childName:)`` in case the path contains an inexistent element at some point.
    /// - Returns: The old element at `path`.
    @inlinable
    @discardableResult
    public mutating func replace(elementAt path: some Collection<Name>, with newElement: XMLElement) throws -> XMLElement {
        try withMutatingAccess(toElementAt: path) { element in
            defer { element = newElement }
            return element
        }
    }

    /// Replaces an element at a given path with a new element.
    /// - Parameters:
    ///   - path: A list of element names which represent the path to the element to replace.
    ///   - newElement: The element insert in place of the element at `path`.
    /// - Throws: ``XMLElement/LookupError/missingChild(element:childName:)``in case the path contains an inexistent element at some point.
    /// - Returns: The old element at `path`.
    @inlinable
    @discardableResult
    public mutating func replace(elementAt path: Name..., with newElement: XMLElement) throws -> XMLElement {
        try replace(elementAt: path, with: newElement)
    }

    /// Removes an element at a given path.
    /// - Parameter path: A collection of element names which represent the path to the element to remove.
    /// - Returns: The removed element or nil if no element was present at the given path or the path was empty.
    /// - Throws: ``XMLElement/LookupError/missingChild(element:childName:)`` in case the path contains an inexistent element at some point.
    ///           The only exception here is the last path element. If it not present, nil is returned instead.
    @discardableResult
    public mutating func remove(elementAt path: some Collection<Name>) throws -> XMLElement? {
        guard !path.isEmpty else { return nil } // We cannot remove anything at a non-existent path.
        let name = path[path.index(path.endIndex, offsetBy: -1)]
        return try withMutatingAccess(toElementAt: path.dropLast()) { elem in
            elem.content.firstIndex { $0.element?.name == name }.flatMap { elem.content.remove(at: $0).element }
        }
    }

    /// Removes an element at a given path.
    /// - Parameter path: A list of element names which represent the path to the element to remove.
    /// - Returns: The removed element or nil if no element was present at the given path or the path was empty.
    /// - Throws: ``XMLElement/LookupError/missingChild(element:childName:)`` in case the path contains an inexistent element at some point.
    ///           The only exception here is the last path element. If it not present, nil is returned instead.
    @inlinable
    @discardableResult
    public mutating func remove(elementAt path: Name...) throws -> XMLElement? {
        try remove(elementAt: path)
    }
}

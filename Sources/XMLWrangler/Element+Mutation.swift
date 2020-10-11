extension Element {
    /// Appends a string to the content.
    ///
    /// - Parameter string: The string to append to the content.
    /// - SeeAlso: RangeReplacableCollection.append(string:)
    @inlinable
    public mutating func append(string: String) {
        content.append(string: string)
    }

    /// Appends an element to the content.
    ///
    /// - Parameter object: The element to append to the content.
    /// - SeeAlso: RangeReplacableCollection.append(object:)
    @inlinable
    public mutating func append(object: Element) {
        content.append(object: object)
    }

    /// Appends the contents of a sequence of elements to the content.
    ///
    /// - Parameter objects: The sequence of elements to append to the content.
    /// - SeeAlso: RangeReplacableCollection.append(contentsOf:)
    @inlinable
    public mutating func append<S: Sequence>(contentsOf objects: S) where S.Element == Element {
        content.append(contentsOf: objects)
    }

    /// Appends one or more objects to the content.
    ///
    /// - Parameter objects: The objects to append to the content.
    /// - SeeAlso: RangeReplacableCollection.append(objects:)
    @inlinable
    public mutating func append(objects: Element...) {
        append(contentsOf: objects)
    }
}

extension Element {
    /// Gives mutating access to an element at a given path.
    ///
    /// - Parameters:
    ///   - path: A collection of element names which represent the path to the element to mutate.
    ///   - work: The closure which is provided with mutating access to the element at the given path.
    /// - Returns: The value returned by `work`.
    /// - Throws: `LookupError.missingChild` in case the path contains an inexistent element at some point. Or any error thrown by `work`
    public mutating func withMutatingAccess<Path: Collection, T>(toElementAt path: Path, do work: (inout Element) throws -> T) throws -> T
    where Path.Element == Name
    {
        guard !path.isEmpty else { return try work(&self) }
        guard let index = content.firstIndex(where: { $0.object?.name == path[path.startIndex] }),
              var object = content[index].object // This one should always succeed.
        else {
            throw LookupError.missingChild(element: self, childElementName: path[path.startIndex])
        }
        defer { content[index] = .object(object) }
        return try object.withMutatingAccess(toElementAt: path.dropFirst(), do: work)
    }

    /// Gives mutating access to an element at a given path.
    ///
    /// - Parameters:
    ///   - path: A list of element names which represent the path to the element to mutate.
    ///   - work: The closure which is provided with mutating access to the element at the given path.
    /// - Returns: The value returned by `work`.
    /// - Throws: `LookupError.missingChild` in case the path contains an inexistent element at some point. Or any error thrown by `work`
    @inlinable
    public mutating func withMutatingAccess<T>(toElementAt path: Name..., do work: (inout Element) throws -> T) throws -> T {
        try withMutatingAccess(toElementAt: path, do: work)
    }

    /// Replaces an element at a given path with a new element.
    ///
    /// - Parameters:
    ///   - path: A collection of element names which represent the path to the element to replace.
    ///   - newElement: The element insert in place of the element at `path`.
    /// - Throws: `LookupError.missingChild` in case the path contains an inexistent element at some point.
    @inlinable
    public mutating func replace<Path: Collection>(elementAt path: Path, with newElement: Element) throws
    where Path.Element == Name
    {
        try withMutatingAccess(toElementAt: path) { $0 = newElement }
    }

    /// Replaces an element at a given path with a new element.
    ///
    /// - Parameters:
    ///   - path: A list of element names which represent the path to the element to replace.
    ///   - newElement: The element insert in place of the element at `path`.
    /// - Throws: `LookupError.missingChild` in case the path contains an inexistent element at some point.
    @inlinable
    public mutating func replace(elementAt path: Name..., with newElement: Element) throws {
        try replace(elementAt: path, with: newElement)
    }

    /// Removes an element at a given path.
    ///
    /// - Parameter path: A collection of element names which represent the path to the element to remove.
    /// - Returns: The removed element or nil if no element was present at the given path or the path was empty.
    /// - Throws: `LookupError.missingChild` in case the path contains an inexistent element at some point.
    ///           The only exception here is the last path element. If it not present, nil is returned instead.
    @discardableResult
    public mutating func remove<Path: Collection>(elementAt path: Path) throws -> Element? where Path.Element == Name {
        guard !path.isEmpty else { return nil } // We cannot remove anything at a non-existent path.
        let name = path[path.index(path.endIndex, offsetBy: -1)]
        return try withMutatingAccess(toElementAt: path.dropLast()) { elem in
            elem.content.firstIndex { $0.object?.name == name }.flatMap { elem.content.remove(at: $0).object }
        }
    }

    /// Removes an element at a given path.
    ///
    /// - Parameter path: A list of element names which represent the path to the element to remove.
    /// - Returns: The removed element or nil if no element was present at the given path or the path was empty.
    /// - Throws: `LookupError.missingChild` in case the path contains an inexistent element at some point.
    ///           The only exception here is the last path element. If it not present, nil is returned instead.
    @inlinable
    @discardableResult
    public mutating func remove(elementAt path: Name...) throws -> Element? {
        try remove(elementAt: path)
    }
}

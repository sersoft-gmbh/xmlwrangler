extension XMLElement.Content.Element {
    /// Returns `true` if `self` is `.string`, `false` otherwise.
    @inlinable
    internal var isString: Bool {
        if case .string(_) = self { return true }
        return false
    }

    /// Returns `true` if `self` is `.element`, `false` otherwise.
    @inlinable
    internal var isElement: Bool {
        if case .element(_) = self { return true }
        return false
    }

    /// Returns the associated `XMLElement` if `self` is `.element`, `nil` otherwise.
    @inlinable
    internal var element: XMLElement? {
        guard case .element(let obj) = self else { return nil }
        return obj
    }

    /// Returns the associated `String` if `self` is `.string`, `nil` otherwise.
    @inlinable
    internal var string: StringPart? {
        guard case .string(let str) = self else { return nil }
        return str
    }
}

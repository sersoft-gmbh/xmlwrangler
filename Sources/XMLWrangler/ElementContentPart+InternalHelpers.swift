extension XMLElement.Content.Element {
    /// Returns `true` if `self` is `.string`, `false` otherwise.
    @inlinable
    internal var isString: Bool {
        if case .string(_) = self { return true }
        return false
    }

    /// Returns `true` if `self` is `.object`, `false` otherwise.
    @inlinable
    internal var isObject: Bool {
        if case .object(_) = self { return true }
        return false
    }

    /// Returns the associated `Element` if `self` is `.object`, `nil` otherwise.
    @inlinable
    internal var object: XMLElement? {
        guard case .object(let obj) = self else { return nil }
        return obj
    }

    /// Returns the associated `String` if `self` is `.string`, `nil` otherwise.
    @inlinable
    internal var string: String? {
        guard case .string(let str) = self else { return nil }
        return str
    }
}

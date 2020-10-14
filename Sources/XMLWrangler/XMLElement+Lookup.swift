// MARK: - Lookup
extension XMLElement {
    // MARK: Single element
    /// Looks up a single child element at a given path of element names.
    ///
    /// - Parameter path: A collection of element names which represent the path to extract the element from.
    /// - Returns: The element at the given path.
    /// - Throws: `LookupError.missingChild` in case the path contains an inexistent element at some point.
    public func element<Path: Collection>(at path: Path) throws -> XMLElement where Path.Element == Name {
        guard !path.isEmpty else { return self }
        guard let nextElement = content.findFirst(elementNamed: path[path.startIndex], recursive: false) else {
            throw LookupError.missingChild(element: self, childElementName: path[path.startIndex])
        }
        return try nextElement.element(at: path.dropFirst())
    }

    /// Looks up a single child element at a given path of element names.
    ///
    /// - Parameter path: A list of element names which represent the path to extract the element from.
    /// - Returns: The element at the given path.
    /// - Throws: `LookupError.missingChild` in case the path contains an inexistent element at some point.
    @inlinable
    public func element(at path: Name...) throws -> XMLElement {
        try element(at: path)
    }

    // MARK: List of elements
    /// Finds all element children with the given name inside the content the element on which this is called.
    ///
    /// - Parameter elementName: The element name for which to look for.
    /// - Returns: All elements found with the given name. Might be empty.
    /// - Throws: Currently, no error is thrown. The method is annotated as `throws` for consistency and because it might throw in the future.
    @inlinable
    public func elements(named elementName: Name) throws -> [XMLElement] {
        content.find(elementsNamed: elementName)
    }
}

// MARK: - Attributes
extension XMLElement {
    // MARK: Retrieval
    /// Returns the value for a given attribute key if present.
    ///
    /// - Parameter key: The key for which to get the attribute value.
    /// - Returns: The attribute value for the given key.
    /// - Throws: `LookupError.missingAttribute` in case no attribute exists for the given key.
    public func attribute(for key: Attributes.Key) throws -> Attributes.Content {
        guard let attribute = attributes[key] else {
            throw LookupError.missingAttribute(element: self, key: key)
        }
        return attribute
    }

    // MARK: Conversion
    /// Returns the result of converting the value for a given attribute key.
    ///
    /// - Parameters:
    ///   - key: The key for which to get the attribute value.
    ///   - converter: The converter to use for the conversion.
    /// - Returns: The converted value.
    /// - Throws: `LookupError.missingAttribute` in case no attribute exists for the given key or any error thrown by `converter`.
    /// - SeeAlso: `Element.attribute(for:)`
    @inlinable
    public func convertedAttribute<T>(for key: Attributes.Key, converter: (Attributes.Content) throws -> T) throws -> T {
        try converter(attribute(for: key))
    }

    /// Returns the result of converting the value for a given attribute key.
    ///
    /// - Parameters:
    ///   - key: The key for which to get the attribute value.
    ///   - converter: The converter to use for the conversion.
    /// - Returns: The converted value.
    /// - Throws: `LookupError.missingAttribute` in case no attribute exists for the given key, `LookupError.cannotConvertAttribute` when `converter` returns nil or any error thrown by `converter`.
    /// - SeeAlso: `Element.attribute(for:)`
    public func convertedAttribute<T>(for key: Attributes.Key, converter: (Attributes.Content) throws -> T?) throws -> T {
        try _convert(attribute(for: key), using: converter,
                     failingWith: LookupError.cannotConvertAttribute(element: self, key: key, type: T.self))
    }

    /// Returns the result of initializing a RawRepresentable type with the value for a given attribute key
    /// passed into the RawValue's LosslessStringConvertible-initializer.
    ///
    /// - Parameter key: The key for which to get the attribute value.
    /// - Returns: An instance of the RawRepresentable type initialized with the attribute value passed into the RawValue's LosslessStringConvertible-initializer.
    /// - Throws: `LookupError.missingAttribute` in case no attribute exists for the given key or `LookupError.cannotConvertAttribute` when the initializer of the RawRepresentable type or its RawValue returns nil.
    /// - SeeAlso: `Element.convertedAttribute(for:converter:)`, `RawRepresentable.init?(rawValue:)` and `LosslessStringConvertible.init?(_:)`
    @inlinable
    public func convertedAttribute<T: RawRepresentable>(for key: Attributes.Key) throws -> T
    where T.RawValue: LosslessStringConvertible
    {
        try convertedAttribute(for: key, converter: { T(rawValueDescription: $0.rawValue) })
    }

    /// Returns the result of initializing a LosslessStringConvertible type with the value for a given attribute key.
    ///
    /// - Parameter key: The key for which to get the attribute value.
    /// - Returns: An instance of the LosslessStringConvertible type initialized with the attribute value.
    /// - Throws: `LookupError.missingAttribute` in case no attribute exists for the given key or `LookupError.cannotConvertAttribute` when the initializer of the LosslessStringConvertible type returns nil.
    /// - SeeAlso: `Element.convertedAttribute(for:converter:)` and `LosslessStringConvertible.init?(_:)`
    @inlinable
    public func convertedAttribute<T: LosslessStringConvertible>(for key: Attributes.Key) throws -> T {
        try convertedAttribute(for: key, converter: { T($0.rawValue) })
    }

    /// Returns the result of initializing a RawRepresentable & LosslessStringConvertible type with the value for a given attribute key
    /// passed into the RawValue's LosslessStringConvertible-initializer.
    ///
    /// - Parameter key: The key for which to get the attribute value.
    /// - Returns: An instance of the RawRepresentable & LosslessStringConvertible type initialized with the attribute value passed into the RawValue's LosslessStringConvertible-initializer.
    /// - Throws: `LookupError.missingAttribute` in case no attribute exists for the given key or `LookupError.cannotConvertAttribute` when the initializer of the RawRepresentable type or its RawValue returns nil.
    /// - SeeAlso: `Element.convertedAttribute(for:converter:)`, `RawRepresentable.init?(rawValue:)` and `LosslessStringConvertible.init?(_:)`
    /// - Note: This overload will prefer the RawRepresentable initializer.
    @inlinable
    public func convertedAttribute<T: RawRepresentable & LosslessStringConvertible>(for key: Attributes.Key) throws -> T
    where T.RawValue: LosslessStringConvertible
    {
        try convertedAttribute(for: key, converter: { T(rawValueDescription: $0.rawValue) })
    }
}

// MARK: - String Content
extension XMLElement {
    // MARK: Retrieval
    /// Returns the combined string content of the element.
    ///
    /// - Returns: All `.string` contents joined together into one string.
    /// - Throws: `LookupError.missingContent` if `content` contains no `.string` elements.
    public func stringContent() throws -> String {
        let stringContent = content.allStrings
        guard !stringContent.isEmpty else { throw LookupError.missingContent(element: self) }
        return stringContent.joined()
    }

    // MARK: Conversion
    /// Returns the result of converting the combined string content.
    ///
    /// - Parameter converter: The converter to use for the conversion.
    /// - Returns: The converted content.
    /// - Throws: `LookupError.missingContent` if `content` contains no `.string` elements or any error thrown by `converter`.
    /// - SeeAlso: `Element.stringContent()`
    @inlinable
    public func convertedStringContent<T>(converter: (String) throws -> T) throws -> T {
        try converter(stringContent())
    }

    /// Returns the result of converting the combined string content.
    ///
    /// - Parameter converter: The converter to use for the conversion.
    /// - Returns: The converted content.
    /// - Throws: `LookupError.missingContent` if `content` contains no `.string` elements, `LookupError.cannotConvertContent` if the `converter` returns nil or any error thrown by `converter`.
    /// - SeeAlso: `Element.stringContent()`
    public func convertedStringContent<T>(converter: (String) throws -> T?) throws -> T {
        let content = try stringContent()
        return try _convert(content, using: converter,
                            failingWith: LookupError.cannotConvertContent(element: self, content: content, type: T.self))
    }

    /// Returns the result of initializing a RawRepresentable type with the combined string content passed into the RawValue's LosslessStringConvertible-initializer.
    ///
    /// - Returns: An instance of the RawRepresentable type initialized with the combined string content passed into the RawValue's LosslessStringConvertible-initializer.
    /// - Throws: `LookupError.missingContent` if `content` contains no `.string` elements, `LookupError.cannotConvertContent` when the initializer of the RawRepresentable type or its RawValue returns nil.
    /// - SeeAlso: `Element.convertedStringContent(converter:)`, `RawRepresentable.init?(rawValue:)` and `LosslessStringConvertible.init?(_:)`
    @inlinable
    public func convertedStringContent<T: RawRepresentable>() throws -> T where T.RawValue: LosslessStringConvertible {
        try convertedStringContent(converter: T.init)
    }

    /// Returns the result of initializing a LosslessStringConvertible type with the combined string content.
    ///
    /// - Returns: An instance of the LosslessStringConvertible type initialized with the combined string content.
    /// - Throws: `LookupError.missingContent` if `content` contains no `.string` elements, `LookupError.cannotConvertContent` when the initializer of the LosslessStringConvertible type returns nil.
    /// - SeeAlso: `Element.convertedStringContent(converter:)` and `LosslessStringConvertible.init?(_:)`
    @inlinable
    public func convertedStringContent<T: LosslessStringConvertible>() throws -> T {
        try convertedStringContent(converter: T.init)
    }

    /// Returns the result of initializing a RawRepresentable & LosslessStringConvertible type with the combined string content passed into the RawValue's LosslessStringConvertible-initializer.
    ///
    /// - Returns: An instance of the RawRepresentable & LosslessStringConvertible type initialized with the combined string content passed into the RawValue's LosslessStringConvertible-initializer.
    /// - Throws: `LookupError.missingContent` if `content` contains no `.string` elements, `LookupError.cannotConvertContent` when the initializer of the RawRepresentable type or its RawValue returns nil.
    /// - SeeAlso: `Element.convertedStringContent(converter:)`, `RawRepresentable.init?(rawValue:)` and `LosslessStringConvertible.init?(_:)`
    /// - Note: This overload will prefer the RawRepresentable initializer.
    @inlinable
    public func convertedStringContent<T: RawRepresentable & LosslessStringConvertible>() throws -> T
    where T.RawValue: LosslessStringConvertible
    {
        try convertedStringContent(converter: T.init(rawValueDescription:))
    }
}

// MARK: - Element Content
extension XMLElement {
    /// Returns the result of converting the receiver to the given `ExpressibleByXMLElement` target.
    /// - Parameter target: The target type to convert to. Defaults to `Target.self`.
    /// - Throws: Any error thrown by `ExpressibleByXMLElement.init(xml:)` of `Target`.
    /// - Returns: The result of calling `Target(xml:)`.
    @inlinable
    public func converted<Target: ExpressibleByXMLElement>(to target: Target.Type = Target.self) throws -> Target {
        try target.init(xml: self)
    }
}

extension Sequence where Element == XMLElement {
    /// Convertes the contents of the sequence to the given target type that conforms to `ExpressibleByXMLElement`.
    /// - Parameter target: The target type to convert the contents to. Defaults to `Target.self`.
    /// - Throws: Any error thrown by `ExpressibleByXMLElement.init(xml:)` of `Target`.
    /// - Returns: The list of converted elements.
    @inlinable
    public func converted<Target: ExpressibleByXMLElement>(to target: Target.Type = Target.self) throws -> Array<Target> {
        try map(target.init)
    }
}

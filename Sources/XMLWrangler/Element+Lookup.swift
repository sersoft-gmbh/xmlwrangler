/// Converts a input value into an output value using a given converter. Throws if the converter returns nil (or throws).
///
/// - Parameters:
///   - input: The input value to convert.
///   - converter: The converter to use for the conversion.
///   - error: The error to throw in case `converter` returns nil.
/// - Returns: The output of the converter.
/// - Throws: `error` in case the `converter` returns nil or any error thrown by `converter`.
fileprivate func convert<Input, Output, Error>(_ input: Input,
                                               using converter: (Input) throws -> Output?,
                                               throwing error: @autoclosure () -> Error) throws -> Output
   where Error: Swift.Error {
      guard let converted = try converter(input) else { throw error() }
      return converted
}

// MARK: - Lookup
public extension Element {
   // MARK: Single element
   /// Looks up a single child element at a given path of element names.
   ///
   /// - Parameter path: A collection of element names which represent the path to extract the element from.
   /// - Returns: The element at the given path.
   /// - Throws: `LookupError.missingChild` in case the path contains an inexistent element at some point.
   public func element<Path: Collection>(at path: Path) throws -> Element where Path.Element == Name {
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
   public func element(at path: Name...) throws -> Element {
      return try element(at: path)
   }

   // MARK: List of elements
   /// Finds all element children with the given name inside the content the element on which this is called.
   ///
   /// - Parameter elementName: The element name for which to look for.
   /// - Returns: All elements found with the given name. Might be empty.
   /// - Throws: Currently, no error is thrown. The method is annotated as `throws` for consistency and because it might throw in the future.
   public func elements(named elementName: Name) throws -> [Element] {
      return content.find(elementsNamed: elementName)
   }

   /// Finds all element children with the given name inside the content a child element which resides at a given path.
   ///
   /// - Parameters:
   ///   - elementName: The element name for which to look for.
   ///   - path: The path of the element in which to search.
   /// - Returns: All elements found with the given name. Might be empty.
   /// - Throws: `LookupError.missingChild` in case the path contains an inexistent element at some point.
   /// - SeeAlso: `Element.element(at:)` and `Element.elements(named:)`
   public func elements<Path: Collection>(named elementName: Name, inElementAt path: Path) throws -> [Element] where Path.Element == Name {
      return try element(at: path).elements(named: elementName)
   }

   /// Finds all element children with the given name inside the content a child element which resides at a given path.
   ///
   /// - Parameters:
   ///   - elementName: The element name for which to look for.
   ///   - path: The path of the element in which to search.
   /// - Returns: All elements found with the given name. Might be empty.
   /// - Throws: `LookupError.missingChild` in case the path contains an inexistent element at some point.
   /// - SeeAlso: `Element.element(at:)` and `Element.elements(named:)`
   public func elements(named elementName: Name, inElementAt path: Name...) throws -> [Element] {
      return try elements(named: elementName, inElementAt: path)
   }
}

// MARK: - Attributes
public extension Element {
   // MARK: Retrieval
   /// Returns the value for a given attribute key if present.
   ///
   /// - Parameter key: The key for which to get the attribute value.
   /// - Returns: The attribute value for the given key.
   /// - Throws: `LookupError.missingAttribute` in case no attribute exists for the given key.
   public func attribute(for key: AttributeKey) throws -> Element.Attributes.Value {
      guard let attribute = attributes[key] else {
         throw LookupError.missingAttribute(element: self, key: key)
      }
      return attribute
   }

   /// Returns the value for a given attribute key of a child element at a given path.
   ///
   /// - Parameters:
   ///   - key: The key for which to get the attribute value.
   ///   - path: The path of the element from which to get the attribute value.
   /// - Returns: The attribute value for the given key of the element at the given path.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element or `LookupError.missingAttribute` in case no attribute exists for the given key.
   /// - SeeAlso: `Element.element(at:)` and `Element.attribute(for:)`.
   @inlinable
   public func attribute<Path: Collection>(for key: AttributeKey, ofElementAt path: Path) throws -> Element.Attributes.Value where Path.Element == Name {
      return try element(at: path).attribute(for: key)
   }

   /// Returns the value for a given attribute key of a child element at a given path.
   ///
   /// - Parameters:
   ///   - key: The key for which to get the attribute value.
   ///   - path: The path of the element from which to get the attribute value.
   /// - Returns: The attribute value for the given key of the element at the given path.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element or `LookupError.missingAttribute` in case no attribute exists for the given key.
   /// - SeeAlso: `Element.element(at:)` and `Element.attribute(for:)`.
   @inlinable
   public func attribute(for key: AttributeKey, ofElementAt path: Name...) throws -> Element.Attributes.Value {
      return try attribute(for: key, ofElementAt: path)
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
   public func convertedAttribute<T>(for key: AttributeKey, converter: (Element.Attributes.Value) throws -> T) throws -> T {
      return try converter(attribute(for: key))
   }

   /// Returns the result of converting the value for a given attribute key.
   ///
   /// - Parameters:
   ///   - key: The key for which to get the attribute value.
   ///   - converter: The converter to use for the conversion.
   /// - Returns: The converted value.
   /// - Throws: `LookupError.missingAttribute` in case no attribute exists for the given key, `LookupError.cannotConvertAttribute` when `converter` returns nil or any error thrown by `converter`.
   /// - SeeAlso: `Element.attribute(for:)`
   public func convertedAttribute<T>(for key: AttributeKey, converter: (Element.Attributes.Value) throws -> T?) throws -> T {
      return try convert(attribute(for: key), using: converter,
                         throwing: LookupError.cannotConvertAttribute(element: self, key: key, type: T.self))
   }

   /// Returns the result of initializing a RawRepresentable type with the value for a given attribute key.
   ///
   /// - Parameter key: The key for which to get the attribute value.
   /// - Returns: An instance of the RawRepresentable type initialized with the attribute value.
   /// - Throws: `LookupError.missingAttribute` in case no attribute exists for the given key or `LookupError.cannotConvertAttribute` when the initializer of the RawRepresentable type returns nil.
   /// - SeeAlso: `Element.convertedAttribute(for:converter:)` and `RawRepresentable.init?(rawValue:)`
   @inlinable
   public func convertedAttribute<T: RawRepresentable>(for key: AttributeKey) throws -> T where T.RawValue == Element.Attributes.Value {
      return try convertedAttribute(for: key, converter: T.init)
   }

   /// Returns the result of initializing a LosslessStringConvertible type with the value for a given attribute key.
   ///
   /// - Parameter key: The key for which to get the attribute value.
   /// - Returns: An instance of the LosslessStringConvertible type initialized with the attribute value.
   /// - Throws: `LookupError.missingAttribute` in case no attribute exists for the given key or `LookupError.cannotConvertAttribute` when the initializer of the LosslessStringConvertible type returns nil.
   /// - SeeAlso: `Element.convertedAttribute(for:converter:)` and `LosslessStringConvertible.init?(_:)`
   @inlinable
   public func convertedAttribute<T: LosslessStringConvertible>(for key: AttributeKey) throws -> T {
      return try convertedAttribute(for: key, converter: T.init)
   }

   /// Returns the result of converting the attribute value for a given attribute key of a child element at a given path.
   ///
   /// - Parameters:
   ///   - key: The key for which to get the attribute value.
   ///   - path: The path of the element from which to get the attribute value.
   ///   - converter: The converter to use for the conversion.
   /// - Returns: The converted value.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element, `LookupError.missingAttribute` in case no attribute exists for the given key or any error thrown by `converter`.
   /// - SeeAlso: `Element.element(at:)` and `Element.convertedAttribute(for:converter:)`
   @inlinable
   public func convertedAttribute<Path: Collection, T>(for key: AttributeKey, ofElementAt path: Path, converter: (Element.Attributes.Value) throws -> T) throws -> T where Path.Element == Name {
      return try element(at: path).convertedAttribute(for: key, converter: converter)
   }

   /// Returns the result of converting the attribute value for a given attribute key of a child element at a given path.
   ///
   /// - Parameters:
   ///   - key: The key for which to get the attribute value.
   ///   - path: The path of the element from which to get the attribute value.
   ///   - converter: The converter to use for the conversion.
   /// - Returns: The converted value.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element, `LookupError.missingAttribute` in case no attribute exists for the given key, `LookupError.cannotConvertAttribute` when `converter` returns nil or any error thrown by `converter`.
   /// - SeeAlso: `Element.element(at:)` and `Element.convertedAttribute(for:converter:)`
   @inlinable
   public func convertedAttribute<Path: Collection, T>(for key: AttributeKey, ofElementAt path: Path, converter: (Element.Attributes.Value) throws -> T?) throws -> T where Path.Element == Name {
      return try element(at: path).convertedAttribute(for: key, converter: converter)
   }

   /// Returns the result of initializing a RawRepresentable type with the value for a given attribute key of a child element at a given path.
   ///
   /// - Parameters:
   ///   - key: The key for which to get the attribute value.
   ///   - path: The path of the element from which to get the attribute value.
   /// - Returns: An instance of the RawRepresentable type initialized with the attribute value.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element, `LookupError.missingAttribute` in case no attribute exists for the given key or `LookupError.cannotConvertAttribute` when the initializer of the RawRepresentable type returns nil.
   /// - SeeAlso: `Element.convertedAttribute(for:ofElementAt:converter:)` and `RawRepresentable.init?(rawValue:)`
   @inlinable
   public func convertedAttribute<Path: Collection, T: RawRepresentable>(for key: AttributeKey, ofElementAt path: Path) throws -> T where Path.Element == Name, T.RawValue == Element.Attributes.Value {
      return try convertedAttribute(for: key, ofElementAt: path, converter: T.init)
   }

   /// Returns the result of initializing a LosslessStringConvertible type with the value for a given attribute key of a child element at a given path.
   ///
   /// - Parameters:
   ///   - key: The key for which to get the attribute value.
   ///   - path: The path of the element from which to get the attribute value.
   /// - Returns: An instance of the LosslessStringConvertible type initialized with the attribute value.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element, `LookupError.missingAttribute` in case no attribute exists for the given key or `LookupError.cannotConvertAttribute` when the initializer of the LosslessStringConvertible type returns nil.
   /// - SeeAlso: `Element.convertedAttribute(for:ofElementAt:converter:)` and `LosslessStringConvertible.init?(_:)`
   @inlinable
   public func convertedAttribute<Path: Collection, T: LosslessStringConvertible>(for key: AttributeKey, ofElementAt path: Path) throws -> T where Path.Element == Name {
      return try convertedAttribute(for: key, ofElementAt: path, converter: T.init)
   }

   /// Returns the result of converting the attribute value for a given attribute key of a child element at a given path.
   ///
   /// - Parameters:
   ///   - key: The key for which to get the attribute value.
   ///   - path: The path of the element from which to get the attribute value.
   ///   - converter: The converter to use for the conversion.
   /// - Returns: The converted value.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element, `LookupError.missingAttribute` in case no attribute exists for the given key or any error thrown by `converter`.
   /// - SeeAlso: `Element.element(at:)` and `Element.convertedAttribute(for:converter:)`
   @inlinable
   public func convertedAttribute<T>(for key: AttributeKey, ofElementAt path: Name..., converter: (Element.Attributes.Value) throws -> T) throws -> T {
      return try element(at: path).convertedAttribute(for: key, converter: converter)
   }

   /// Returns the result of converting the attribute value for a given attribute key of a child element at a given path.
   ///
   /// - Parameters:
   ///   - key: The key for which to get the attribute value.
   ///   - path: The path of the element from which to get the attribute value.
   ///   - converter: The converter to use for the conversion.
   /// - Returns: The converted value.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element, `LookupError.missingAttribute` in case no attribute exists for the given key, `LookupError.cannotConvertAttribute` when `converter` returns nil or any error thrown by `converter`.
   /// - SeeAlso: `Element.element(at:)` and `Element.convertedAttribute(for:converter:)`
   @inlinable
   public func convertedAttribute<T>(for key: AttributeKey, ofElementAt path: Name..., converter: (Element.Attributes.Value) throws -> T?) throws -> T {
      return try element(at: path).convertedAttribute(for: key, converter: converter)
   }

   /// Returns the result of initializing a RawRepresentable type with the value for a given attribute key of a child element at a given path.
   ///
   /// - Parameters:
   ///   - key: The key for which to get the attribute value.
   ///   - path: The path of the element from which to get the attribute value.
   /// - Returns: An instance of the RawRepresentable type initialized with the attribute value.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element, `LookupError.missingAttribute` in case no attribute exists for the given key or `LookupError.cannotConvertAttribute` when the initializer of the RawRepresentable type returns nil.
   /// - SeeAlso: `Element.convertedAttribute(for:ofElementAt:converter:)` and `RawRepresentable.init?(rawValue:)`
   @inlinable
   public func convertedAttribute<T: RawRepresentable>(for key: AttributeKey, ofElementAt path: Name...) throws -> T where T.RawValue == Element.Attributes.Value {
      return try convertedAttribute(for: key, ofElementAt: path, converter: T.init)
   }

   /// Returns the result of initializing a LosslessStringConvertible type with the value for a given attribute key of a child element at a given path.
   ///
   /// - Parameters:
   ///   - key: The key for which to get the attribute value.
   ///   - path: The path of the element from which to get the attribute value.
   /// - Returns: An instance of the LosslessStringConvertible type initialized with the attribute value.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element, `LookupError.missingAttribute` in case no attribute exists for the given key or `LookupError.cannotConvertAttribute` when the initializer of the LosslessStringConvertible type returns nil.
   /// - SeeAlso: `Element.convertedAttribute(for:ofElementAt:converter:)` and `LosslessStringConvertible.init?(_:)`
   @inlinable
   public func convertedAttribute<T: LosslessStringConvertible>(for key: AttributeKey, ofElementAt path: Name...) throws -> T {
      return try convertedAttribute(for: key, ofElementAt: path, converter: T.init)
   }
}

// MARK: - String Content
public extension Element {
   // MARK: Retrieval
   /// Returns the combined string content of the element.
   ///
   /// - Returns: All `.string` contents joined together into one string.
   /// - Throws: `LookupError.missingContent` if `content` contains no `.string` objects.
   public func stringContent() throws -> String {
      let stringContent = content.allStrings
      guard !stringContent.isEmpty else { throw LookupError.missingContent(element: self) }
      return stringContent.joined()
   }

   /// Returns the combined string content of a child element at a given path.
   ///
   /// - Parameter path: The path of the element from which to get the string content value.
   /// - Returns: The combined string content of the element at the given path.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element or `LookupError.missingContent` if `content` contains no `.string` objects.
   @inlinable
   public func stringContent<Path: Collection>(ofElementAt path: Path) throws -> String where Path.Element == Name {
      return try element(at: path).stringContent()
   }

   /// Returns the combined string content of a child element at a given path.
   ///
   /// - Parameter path: The path of the element from which to get the string content value.
   /// - Returns: The combined string content of the element at the given path.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element or `LookupError.missingContent` if `content` contains no `.string` objects.
   @inlinable
   public func stringContent(ofElementAt path: Name...) throws -> String {
      return try stringContent(ofElementAt: path)
   }

   // MARK: Conversion
   /// Returns the result of converting the combined string content.
   ///
   /// - Parameter converter: The converter to use for the conversion.
   /// - Returns: The converted content.
   /// - Throws: `LookupError.missingContent` if `content` contains no `.string` objects or any error thrown by `converter`.
   /// - SeeAlso: `Element.stringContent()`
   @inlinable
   public func convertedStringContent<T>(converter: (String) throws -> T) throws -> T {
      return try converter(stringContent())
   }

   /// Returns the result of converting the combined string content.
   ///
   /// - Parameter converter: The converter to use for the conversion.
   /// - Returns: The converted content.
   /// - Throws: `LookupError.missingContent` if `content` contains no `.string` objects, `LookupError.cannotConvertContent` if the `converter` returns nil or any error thrown by `converter`.
   /// - SeeAlso: `Element.stringContent()`
   public func convertedStringContent<T>(converter: (String) throws -> T?) throws -> T {
      let content = try stringContent()
      return try convert(content, using: converter,
                         throwing: LookupError.cannotConvertContent(element: self, content: content, type: T.self))
   }

   /// Returns the result of initializing a RawRepresentable type with the combined string content.
   ///
   /// - Returns: An instance of the RawRepresentable type initialized with the combined string content.
   /// - Throws: `LookupError.missingContent` if `content` contains no `.string` objects, `LookupError.cannotConvertContent` when the initializer of the RawRepresentable type returns nil.
   /// - SeeAlso: `Element.convertedStringContent(converter:)` and `RawRepresentable.init?(rawValue:)`
   @inlinable
   public func convertedStringContent<T: RawRepresentable>() throws -> T where T.RawValue == String {
      return try convertedStringContent(converter: T.init)
   }

   /// Returns the result of initializing a LosslessStringConvertible type with the combined string content.
   ///
   /// - Returns: An instance of the LosslessStringConvertible type initialized with the combined string content.
   /// - Throws: `LookupError.missingContent` if `content` contains no `.string` objects, `LookupError.cannotConvertContent` when the initializer of the LosslessStringConvertible type returns nil.
   /// - SeeAlso: `Element.convertedStringContent(converter:)` and `LosslessStringConvertible.init?(_:)`
   public func convertedStringContent<T: LosslessStringConvertible>() throws -> T {
      return try convertedStringContent(converter: T.init)
   }

   /// Returns the result of converting the combined string content of a child element at a given path.
   ///
   /// - Parameters:
   ///   - path: The path of the element from which to get the string content value.
   ///   - converter: The converter to use for the conversion.
   /// - Returns: The converted value.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element, `LookupError.missingContent` if `content` contains no `.string` objects or any error thrown by `converter`.
   /// - SeeAlso: `Element.element(at:)` and `Element.convertedStringContent(converter:)`
   @inlinable
   public func convertedStringContent<Path: Collection, T>(ofElementAt path: Path, converter: (String) throws -> T) throws -> T where Path.Element == Name {
      return try element(at: path).convertedStringContent(converter: converter)
   }

   /// Returns the result of converting the combined string content of a child element at a given path.
   ///
   /// - Parameters:
   ///   - path: The path of the element from which to get the string content value.
   ///   - converter: The converter to use for the conversion.
   /// - Returns: The converted value.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element, `LookupError.missingContent` if `content` contains no `.string` objects, `LookupError.cannotConvertContent` if the `converter` returns nil or any error thrown by `converter`.
   /// - SeeAlso: `Element.element(at:)` and `Element.convertedStringContent(converter:)`
   @inlinable
   public func convertedStringContent<Path: Collection, T>(ofElementAt path: Path, converter: (String) throws -> T?) throws -> T where Path.Element == Name {
      return try element(at: path).convertedStringContent(converter: converter)
   }

   /// Returns the result of initializing a RawRepresentable type with the combined string content of a child element at a given path.
   ///
   /// - Parameter path: The path of the element from which to get the string content value.
   /// - Returns: An instance of the RawRepresentable type initialized with the combined string content.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element, `LookupError.missingContent` if `content` contains no `.string` objects, `LookupError.cannotConvertContent` when the initializer of the RawRepresentable type returns nil.
   /// - SeeAlso: `Element.convertedStringContent(ofElementAt:converter:)` and `RawRepresentable.init?(rawValue:)`
   @inlinable
   public func convertedStringContent<Path: Collection, T: RawRepresentable>(ofElementAt path: Path) throws -> T where Path.Element == Name, T.RawValue == String {
      return try convertedStringContent(ofElementAt: path, converter: T.init)
   }

   /// Returns the result of initializing a LosslessStringConvertible type with the combined string content of a child element at a given path.
   ///
   /// - Parameter path: The path of the element from which to get the string content value.
   /// - Returns: An instance of the LosslessStringConvertible type initialized with the combined string content.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element, `LookupError.missingContent` if `content` contains no `.string` objects, `LookupError.cannotConvertContent` when the initializer of the LosslessStringConvertible type returns nil.
   /// - SeeAlso: `Element.convertedStringContent(ofElementAt:converter:)` and `LosslessStringConvertible.init?(_:)`
   @inlinable
   public func convertedStringContent<Path: Collection, T: LosslessStringConvertible>(ofElementAt path: Path) throws -> T where Path.Element == Name {
      return try convertedStringContent(ofElementAt: path, converter: T.init)
   }

   /// Returns the result of converting the combined string content of a child element at a given path.
   ///
   /// - Parameters:
   ///   - path: The path of the element from which to get the string content value.
   ///   - converter: The converter to use for the conversion.
   /// - Returns: The converted value.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element, `LookupError.missingContent` if `content` contains no `.string` objects or any error thrown by `converter`.
   /// - SeeAlso: `Element.element(at:)` and `Element.convertedStringContent(converter:)`
   @inlinable
   public func convertedStringContent<T>(ofElementAt path: Name..., converter: (String) throws -> T) throws -> T {
      return try element(at: path).convertedStringContent(converter: converter)
   }

   /// Returns the result of converting the combined string content of a child element at a given path.
   ///
   /// - Parameters:
   ///   - path: The path of the element from which to get the string content value.
   ///   - converter: The converter to use for the conversion.
   /// - Returns: The converted value.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element, `LookupError.missingContent` if `content` contains no `.string` objects, `LookupError.cannotConvertContent` if the `converter` returns nil or any error thrown by `converter`.
   /// - SeeAlso: `Element.element(at:)` and `Element.convertedStringContent(converter:)`
   @inlinable
   public func convertedStringContent<T>(ofElementAt path: Name..., converter: (String) throws -> T?) throws -> T {
      return try element(at: path).convertedStringContent(converter: converter)
   }

   /// Returns the result of initializing a RawRepresentable type with the combined string content of a child element at a given path.
   ///
   /// - Parameter path: The path of the element from which to get the string content value.
   /// - Returns: An instance of the RawRepresentable type initialized with the combined string content.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element, `LookupError.missingContent` if `content` contains no `.string` objects, `LookupError.cannotConvertContent` when the initializer of the RawRepresentable type returns nil.
   /// - SeeAlso: `Element.convertedStringContent(ofElementAt:converter:)` and `RawRepresentable.init?(rawValue:)`
   @inlinable
   public func convertedStringContent<T: RawRepresentable>(ofElementAt path: Name...) throws -> T where T.RawValue == String {
      return try convertedStringContent(ofElementAt: path, converter: T.init)
   }

   /// Returns the result of initializing a LosslessStringConvertible type with the combined string content of a child element at a given path.
   ///
   /// - Parameter path: The path of the element from which to get the string content value.
   /// - Returns: An instance of the LosslessStringConvertible type initialized with the combined string content.
   /// - Throws: `LookupError.missingChild` if the path contains an inexistent element, `LookupError.missingContent` if `content` contains no `.string` objects, `LookupError.cannotConvertContent` when the initializer of the LosslessStringConvertible type returns nil.
   /// - SeeAlso: `Element.convertedStringContent(ofElementAt:converter:)` and `LosslessStringConvertible.init?(_:)`
   @inlinable
   public func convertedStringContent<T: LosslessStringConvertible>(ofElementAt path: Name...) throws -> T {
      return try convertedStringContent(ofElementAt: path, converter: T.init)
   }
}

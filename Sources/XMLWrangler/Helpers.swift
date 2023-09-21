/// Converts a input value into an output value using a given converter. Throws if the converter returns nil (or throws).
/// - Parameters:
///   - input: The input value to convert.
///   - converter: The converter to use for the conversion.
///   - error: The error to throw in case `converter` returns nil.
/// - Returns: The output of the converter.
/// - Throws: `error` in case the `converter` returns nil or any error thrown by `converter`.
@inlinable
func _convert<Input, Output>(_ input: Input,
                             using converter: (Input) throws -> Output?,
                             failingWith error: @autoclosure () -> some Error) throws -> Output {
    guard let converted = try converter(input) else { throw error() }
    return converted
}

extension RawRepresentable where RawValue: LosslessStringConvertible {
    /// Creates an instance of self from the description of the `RawValue`. Returns nil if nil is returned by `RawValue.init(_:)`
    /// - Parameter rawValueDescription: The description of the `RawValue` to use to try to create an instance.
    @inlinable
    init?(rawValueDescription: String) {
        guard let rawValue = RawValue(rawValueDescription) else { return nil }
        self.init(rawValue: rawValue)
    }
}

extension Dictionary where Key == XMLElement.Attributes.Key.RawValue, Value == XMLElement.Attributes.Content.RawValue {
    /// Converts the receiver to the ``XMLElement/Attributes`` type.
    @inlinable
    var asAttributes: XMLElement.Attributes {
        .init(storage: .init(uniqueKeysWithValues: lazy.map { (.init(rawValue: $0.key), .init(rawValue: $0.value)) }))
    }
}

extension RandomAccessCollection {
    /// Returns the last safe subscript index.
    @inlinable
    var indexBeforeEndIndex: Index { index(before: endIndex) }
}

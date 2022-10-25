/// Describes a type that can be initialized with an ``XMLElement``.
public protocol ExpressibleByXMLElement {
    /// Creates a new instance using the given ``XMLElement``.
    /// - Parameter xml: The xml to initialize from.
    init(xml: XMLElement) throws
}

/// Describes a type that can be converted to an ``XMLElement``.
public protocol XMLElementConvertible {
    /// The ``XMLElement`` representing this instance.
    var xml: XMLElement { get }
}

/// A type that can be converted from and to an ``XMLElement``.
public typealias XMLElementRepresentable = ExpressibleByXMLElement & XMLElementConvertible

extension ExpressibleByXMLElement {
    @usableFromInline
    static func _fromContent(of element: XMLElement, converter: (XMLElement.Content.Element.StringPart) -> Self?) throws -> Self {
        try element.convertedStringContent(converter: converter)
    }

    @inlinable
    static func _fromContent<T: LosslessStringConvertible>(of element: XMLElement, converter: (T) -> Self?) throws -> Self {
        try _fromContent(of: element, converter: { T($0).flatMap(converter) })
    }
}

extension ExpressibleByXMLElement where Self: RawRepresentable, Self.RawValue: LosslessStringConvertible {
    @inlinable
    public init(xml: XMLElement) throws {
        self = try Self._fromContent(of: xml, converter: Self.init)
    }
}

extension ExpressibleByXMLElement where Self: LosslessStringConvertible {
    @inlinable
    public init(xml: XMLElement) throws {
        self = try Self._fromContent(of: xml, converter: Self.init)
    }
}

extension ExpressibleByXMLElement where Self: LosslessStringConvertible, Self: RawRepresentable, Self.RawValue: LosslessStringConvertible {
    @inlinable
    public init(xml: XMLElement) throws {
        self = try Self._fromContent(of: xml, converter: Self.init(rawValue:))
    }
}

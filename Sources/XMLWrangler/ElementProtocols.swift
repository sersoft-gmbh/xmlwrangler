/// Describes a type that can be initialized with an XML `Element`.
public protocol ExpressibleByXMLElement {
    /// Creates a new instance using the given XML `Element`.
    /// - Parameter xml: The xml to initialize from.
    init(xml: Element) throws
}

/// Describes a type that can be converted to an XML `Element`.
public protocol XMLElementConvertible {
    /// The XML `Element` representing this instance.
    var xml: Element { get }
}

/// A type that can be converted from and to an XML `Element`.
public typealias XMLElementRepresentable = ExpressibleByXMLElement & XMLElementConvertible

extension Element: XMLElementRepresentable {
    /// inherited
    @inlinable
    public var xml: Element { self }

    /// inherited
    @inlinable
    public init(xml: Element) { self = xml }
}

extension ExpressibleByXMLElement {
    @usableFromInline
    static func _fromContent(of element: Element, converter: (String) -> Self?) throws -> Self {
        try element.convertedStringContent(converter: converter)
    }

    @inlinable
    static func _fromContent<T: LosslessStringConvertible>(of element: Element, converter: (T) -> Self?) throws -> Self {
        try _fromContent(of: element, converter: { T($0).flatMap(converter) })
    }
}

extension ExpressibleByXMLElement where Self: RawRepresentable, Self.RawValue: LosslessStringConvertible {
    /// inherited
    @inlinable
    public init(xml: Element) throws {
        self = try Self._fromContent(of: xml, converter: Self.init)
    }
}

extension ExpressibleByXMLElement where Self: LosslessStringConvertible {
    /// inherited
    @inlinable
    public init(xml: Element) throws {
        self = try Self._fromContent(of: xml, converter: Self.init)
    }
}

extension ExpressibleByXMLElement where Self: LosslessStringConvertible, Self: RawRepresentable, Self.RawValue: LosslessStringConvertible {
    /// inherited
    @inlinable
    public init(xml: Element) throws {
        self = try Self._fromContent(of: xml, converter: Self.init(rawValue:))
    }
}

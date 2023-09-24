@frozen
@resultBuilder
public enum XMLContentBuilder: Sendable {
    @inlinable
    public static func buildExpression(_ element: XMLElement.Content.Element) -> XMLElement.Content {
        .init(storage: [element])
    }

    @inlinable
    public static func buildExpression(_ element: XMLElement) -> XMLElement.Content {
        .init(storage: [.element(element)])
    }

    @inlinable
    public static func buildExpression(_ element: String) -> XMLElement.Content {
        .init(storage: [.string(element)])
    }

    @inlinable
    public static func buildExpression(_ element: some XMLElementConvertible) -> XMLElement.Content {
        .init(storage: [.element(element.xml)])
    }

    @inlinable
    public static func buildBlock() -> XMLElement.Content { .init(storage: .init()) }

    @inlinable
    public static func buildBlock(_ content: XMLElement.Content) -> XMLElement.Content {
        content
    }

    @inlinable
    public static func buildBlock(_ content: XMLElement.Content...) -> XMLElement.Content {
        .init(storage: content.flatMap(\.storage))
    }

    @inlinable
    public static func buildOptional(_ content: XMLElement.Content?) -> XMLElement.Content {
        content ?? .init(storage: .init())
    }

    @inlinable
    public static func buildEither(first: XMLElement.Content) -> XMLElement.Content {
        first
    }

    @inlinable
    public static func buildEither(second: XMLElement.Content) -> XMLElement.Content {
        second
    }

    @inlinable
    public static func buildArray(_ content: Array<XMLElement.Content>) -> XMLElement.Content {
        .init(storage: content.flatMap(\.storage))
    }

    @inlinable
    public static func buildFinalResult(_ content: XMLElement.Content) -> XMLElement.Content {
        content._compressed(stringSeparator: "\n") // for builder-built strings we use a newline separator
    }
}

extension XMLElement {
    /// Creates a new element using the given name and attributes. The content is built using the ``XMLContentBuilder``.
    /// - Parameters:
    ///   - name: The name of the new element.
    ///   - attributes: The attributes of the new element.
    ///   - content: The content builder to use for the content.
    @inlinable
    public init(name: Name,
                attributes: Attributes = .init(), 
                @XMLContentBuilder content: () throws -> Content) rethrows {
        try self.init(name: name, attributes: attributes, content: content())
    }
}

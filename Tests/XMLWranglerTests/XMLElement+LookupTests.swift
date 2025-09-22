import Testing
@testable import XMLWrangler

extension XMLElementTests {
    @Suite
    struct LookupTests {
        private struct StringInitializable: Equatable {
            let strValue: String
            init(str: String) { strValue = str }
        }

        private struct NotStringInitializable {
            init?(str: String) { nil }
        }

        private struct StringRepresentable: RawRepresentable, Equatable {
            let rawValue: String
            init(rawValue: String) { self.rawValue = rawValue }
        }

        private struct StringConvertible: LosslessStringConvertible, Equatable {
            let description: String
            init(_ description: String) { self.description = description }
        }

        private enum StringConvertibleAndRepresentable: RawRepresentable, LosslessStringConvertible, Equatable {
            case rawValue(String)
            case description(String)

            var stringValue: String {
                switch self {
                case .rawValue(let rawValue): rawValue
                case .description(let description): description
                }
            }

            var rawValue: String { stringValue }
            var description: String { stringValue }

            init(rawValue: String) { self = .rawValue(rawValue) }
            init(_ description: String) { self = .description(description) }
        }

        private struct StringRepresentableWithNotConvertibleRawValue: RawRepresentable, Equatable {
            struct RawValue: LosslessStringConvertible, Equatable {
                var description: String { "How on earth did you get here?" }
                init?(_ description: String) { nil }
            }

            let rawValue: RawValue
            init(rawValue: RawValue) { self.rawValue = rawValue }
        }

        private struct AttributeExpressible: ExpressibleByXMLAttributeContent {
            let xmlAttributeContent: XWElement.Attributes.Content
        }

        private struct AttributeExpressibleAndRaw: RawRepresentable, ExpressibleByXMLAttributeContent {
            typealias RawValue = String

            let rawValue: RawValue

            init(rawValue: RawValue) { self.rawValue = rawValue }
        }

        private struct AttributeExpressibleAndLossLess: LosslessStringConvertible, ExpressibleByXMLAttributeContent {
            let description: String

            init(_ description: String) { self.description = description }
        }

        private struct AttributeExpressibleAndBoth: RawRepresentable, LosslessStringConvertible, ExpressibleByXMLAttributeContent {
            typealias RawValue = String

            let rawValue: RawValue
            var description: String { rawValue }

            init(rawValue: RawValue) { self.rawValue = rawValue }
            init(_ description: String) { self.init(rawValue: description) }
        }

        private struct ElementExpressible: ExpressibleByXMLElement {
            let element: XWElement

            init(xml: XWElement) throws { element = xml }
        }

        let sut = XWElement(name: "root", attributes: ["version": "2.3.4"], elements: [
            XWElement(name: "member", elements: [XWElement(name: "kind", content: "value")]),
            XWElement(name: "empty_member", attributes: ["active": "true", "id": "5"]),
            XWElement(name: "bigger", attributes: ["date": "2018-01-03"], elements: [
                XWElement(name: "children", elements: [
                    XWElement(name: "child", elements: [
                        XWElement(name: "void"),
                        XWElement(name: "texts", content: [
                            .element(XWElement(name: "not_filled")),
                            .string("Huh?"),
                            .element(XWElement(name: "nested_text", content: "This is a text")),
                            .string("More text"),
                        ]),
                    ]),
                    XWElement(name: "child", content: "with not much content"),
                    XWElement(name: "child"),
                ]),
                XWElement(name: "again_not_much", attributes: ["value": "124.56"]),
                XWElement(name: "stringy", content: [
                    .string("Some text"),
                    .element(XWElement(name: "an_object")),
                    .string("More text"),
                ]),
                XWElement(name: "not_stringy"),
            ]),
            XWElement(name: "big", elements: [
                XWElement(name: "boring"),
                XWElement(name: "pets", elements: [
                    XWElement(name: "dog", attributes: ["name": "Fifi"]),
                    XWElement(name: "dog", attributes: ["name": "Fred"]),
                    XWElement(name: "dog", attributes: ["name": "Pete"]),
                    XWElement(name: "dog", attributes: ["name": "Max"]),
                ]),
            ]),
            XWElement(name: "simple", elements: XWElement(name: "simple_child")),
            XWElement(name: "repeating", attributes: ["repeat_count": "1"]),
            XWElement(name: "repeating", attributes: ["repeat_count": "2"]),
            XWElement(name: "repeating", attributes: ["repeat_count": "3"]),
            XWElement(name: "last"),
        ])

        let stringContentSUT = XWElement(name: "string_content", content: "we have content")
        let noStringContentSUT = XWElement(name: "no_string_content")

        // MARK: - Lookup
        // MARK: Single element
        @Test
        func existingElementLookupAtPath() throws {
            let target = try sut.element(at: ["bigger", "children", "child", "void"])
            #expect(target == XWElement(name: "void"))
        }

        @Test
        func nonExistingElementLookupAtPath() {
#if swift(>=6.1)
            let error = #expect(throws: (any Error).self) {
                try sut.element(at: ["simple", "simple_child", "nope"])
            }
#else
            let error: (any Error)?
            do {
                try sut.element(at: ["simple", "simple_child", "nope"])
                error = nil
            } catch let caughtError {
                error = caughtError
            }
#endif
            #expect(error is XWElement.LookupError)
            #expect(error as? XWElement.LookupError == .missingChild(element: XWElement(name: "simple_child"), childName: "nope"))
        }

        @Test
        func existingElementLookupAtVariadicPath() throws {
            let target = try sut.element(at: "bigger", "children", "child", "void")
            #expect(target == XWElement(name: "void"))
        }

        @Test
        func nonExistingElementLookupAtVariadicPath() {
#if swift(>=6.1)
            let error = #expect(throws: (any Error).self) {
                try sut.element(at: "simple", "simple_child", "nope")
            }
#else
            let error: (any Error)?
            do {
                try sut.element(at: "simple", "simple_child", "nope")
                error = nil
            } catch let caughtError {
                error = caughtError
            }
#endif
            #expect(error is XWElement.LookupError)
            #expect(error as? XWElement.LookupError == .missingChild(element: XWElement(name: "simple_child"), childName: "nope"))
        }

        // MARK: List of elements
        @Test
        func existingElementsLookup() throws {
            let elements = try sut.elements(named: "repeating")
            #expect(elements.count == 3)
            #expect(elements == [XWElement(name: "repeating", attributes: ["repeat_count": "1"]),
                                 XWElement(name: "repeating", attributes: ["repeat_count": "2"]),
                                 XWElement(name: "repeating", attributes: ["repeat_count": "3"])])
        }

        @Test
        func nonExistingElementsLookup() throws {
            let elements = try sut.elements(named: "nope")
            #expect(elements.isEmpty)
        }

        // MARK: - Attributes
        // MARK: Retrieval
        @Test
        func existingAttributeLookup() throws {
            let attribute = try sut.attribute(for: "version")
            #expect(attribute == "2.3.4")
        }

        @Test
        func nonExistingAttributeLookup() {
#if swift(>=6.1)
            let error = #expect(throws: (any Error).self) {
                try sut.attribute(for: "nope")
            }
#else
            let error: (any Error)?
            do {
                try sut.attribute(for: "nope")
                error = nil
            } catch let caughtError {
                error = caughtError
            }
#endif
            #expect(error is XWElement.LookupError)
            #expect(error as? XWElement.LookupError == .missingAttribute(element: sut, key: "nope"))
        }

        // MARK: Conversion
        @Test
        func nonExistingAttributeConversion() {
#if swift(>=6.1)
            let error = #expect(throws: (any Error).self) {
                try sut.convertedAttribute(for: "nope", converter: { StringInitializable(str: $0.rawValue) })
            }
#else
            let error: (any Error)?
            do {
                try sut.convertedAttribute(for: "nope", converter: { StringInitializable(str: $0.rawValue) })
                error = nil
            } catch let caughtError {
                error = caughtError
            }
#endif
            #expect(error is XWElement.LookupError)
            #expect(error as? XWElement.LookupError == .missingAttribute(element: sut, key: "nope"))
        }

        @Test
        func existingAttributeConversion() throws {
            let attribute = try sut.convertedAttribute(for: "version", converter: { StringInitializable(str: $0.rawValue) })
            #expect(attribute == StringInitializable(str: "2.3.4"))
        }

        @Test
        func failedExistingAttributeConversion() {
#if swift(>=6.1)
            let error = #expect(throws: (any Error).self) {
                try sut.convertedAttribute(for: "version", converter: { NotStringInitializable(str: $0.rawValue) })
            }
#else
            let error: (any Error)?
            do {
                try sut.convertedAttribute(for: "version", converter: { NotStringInitializable(str: $0.rawValue) })
                error = nil
            } catch let caughtError {
                error = caughtError
            }
#endif
            #expect(error is XWElement.LookupError)
            #expect(error as? XWElement.LookupError == .cannotConvertAttribute(element: sut, key: "version", content: "2.3.4", type: NotStringInitializable.self))
        }

        @Test
        func failedRawRepresentableAttributeConversion() {
#if swift(>=6.1)
            let error = #expect(throws: (any Error).self) {
                try sut.convertedAttribute(
                    for: "version",
                    converter: { StringRepresentableWithNotConvertibleRawValue(rawValueDescription: $0.rawValue) }
                )
            }
#else
            let error: (any Error)?
            do {
                try sut.convertedAttribute(
                    for: "version",
                    converter: { StringRepresentableWithNotConvertibleRawValue(rawValueDescription: $0.rawValue) }
                )
                error = nil
            } catch let caughtError {
                error = caughtError
            }
#endif
            #expect(error is XWElement.LookupError)
            #expect(error as? XWElement.LookupError == .cannotConvertAttribute(element: sut,
                                                                               key: "version",
                                                                               content: "2.3.4",
                                                                               type: StringRepresentableWithNotConvertibleRawValue.self))
        }

        @Test
        func attributeConversionWithStdlibProtocols() throws {
            let rawRep: StringRepresentable = try sut.convertedAttribute(for: "version")
            #expect(rawRep == StringRepresentable(rawValue: "2.3.4"))
            let lossLess: StringConvertible = try sut.convertedAttribute(for: "version")
            #expect(lossLess == StringConvertible("2.3.4"))
            let both: StringConvertibleAndRepresentable = try sut.convertedAttribute(for: "version")
            #expect(both == .rawValue("2.3.4"))
        }

        @Test
        func convertibleAttribute() throws {
            let pure: AttributeExpressible = try sut.convertedAttribute(for: "version")
            #expect(pure.xmlAttributeContent == "2.3.4")
            let andRaw: AttributeExpressibleAndRaw = try sut.convertedAttribute(for: "version")
            #expect(andRaw.rawValue == "2.3.4")
            let andLossLess: AttributeExpressibleAndLossLess = try sut.convertedAttribute(for: "version")
            #expect(andLossLess.description == "2.3.4")
            let andBoth: AttributeExpressibleAndBoth = try sut.convertedAttribute(for: "version")
            #expect(andBoth.rawValue == "2.3.4")
        }

        // MARK: - String Content
        // MARK: Retrieval
        @Test
        func nonExistingStringContentLookup() {
#if swift(>=6.1)
            let error = #expect(throws: (any Error).self) {
                try noStringContentSUT.stringContent()
            }
#else
            let error: (any Error)?
            do {
                try noStringContentSUT.stringContent()
                error = nil
            } catch let caughtError {
                error = caughtError
            }
#endif
            #expect(error is XWElement.LookupError)
            #expect(error as? XWElement.LookupError == .missingStringContent(element: noStringContentSUT))
        }

        @Test
        func existingStringContentLookup() throws {
            let content = try stringContentSUT.stringContent()
            #expect(content == "we have content")
        }

        // MARK: Conversion
        @Test
        func nonExistingStringContentConversion() {
#if swift(>=6.1)
            let error = #expect(throws: (any Error).self) {
                try noStringContentSUT.convertedStringContent(converter: StringInitializable.init)
            }
#else
            let error: (any Error)?
            do {
                try noStringContentSUT.convertedStringContent(converter: StringInitializable.init)
                error = nil
            } catch let caughtError {
                error = caughtError
            }
#endif
            #expect(error is XWElement.LookupError)
            #expect(error as? XWElement.LookupError == .missingStringContent(element: noStringContentSUT))
        }

        @Test
        func existingStringContentConversion() throws {
            let content = try stringContentSUT.convertedStringContent(converter: StringInitializable.init)
            #expect(content == StringInitializable(str: "we have content"))
        }

        @Test
        func failedExistingStringContentConversion() {
#if swift(>=6.1)
            let error = #expect(throws: (any Error).self) {
                try stringContentSUT.convertedStringContent(converter: NotStringInitializable.init)
            }
#else
            let error: (any Error)?
            do {
                try stringContentSUT.convertedStringContent(converter: NotStringInitializable.init)
                error = nil
            } catch let caughtError {
                error = caughtError
            }
#endif
            #expect(error is XWElement.LookupError)
            #expect(error as? XWElement.LookupError == .cannotConvertStringContent(element: stringContentSUT,
                                                                                   stringContent: "we have content",
                                                                                   type: NotStringInitializable.self))
        }

        @Test
        func failedRawRepresentableExistingStringContentConversion() {
#if swift(>=6.1)
            let error = #expect(throws: (any Error).self) {
                try stringContentSUT.convertedStringContent(converter: StringRepresentableWithNotConvertibleRawValue.init)
            }
#else
            let error: (any Error)?
            do {
                try stringContentSUT.convertedStringContent(converter: StringRepresentableWithNotConvertibleRawValue.init)
                error = nil
            } catch let caughtError {
                error = caughtError
            }
#endif
            #expect(error is XWElement.LookupError)
            #expect(error as? XWElement.LookupError == .cannotConvertStringContent(element: stringContentSUT,
                                                                                   stringContent: "we have content",
                                                                                   type: StringRepresentableWithNotConvertibleRawValue.self))
        }

        @Test
        func rawRepresentableStringContentConversion() throws {
            let content: StringRepresentable = try stringContentSUT.convertedStringContent()
            #expect(content == StringRepresentable(rawValue: "we have content"))
        }

        @Test
        func losslessStringConvertibleStringContentConversion() throws {
            let content: StringConvertible = try stringContentSUT.convertedStringContent()
            #expect(content == StringConvertible("we have content"))
        }

        @Test
        func rawRepresentableLosslessStringConvertibleStringContentConversion() throws {
            let content: StringConvertibleAndRepresentable = try stringContentSUT.convertedStringContent()
            #expect(content == .rawValue("we have content"))
        }

        @Test
        func convertingElement() throws {
            #expect(try sut.converted(to: ElementExpressible.self).element == sut)
            #expect(try [sut, stringContentSUT, noStringContentSUT].converted(to: ElementExpressible.self).map(\.element)
                    ==
                    [sut, stringContentSUT, noStringContentSUT])
        }
    }
}

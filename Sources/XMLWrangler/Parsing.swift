public import struct Foundation.Data
public import class Foundation.NSObject
#if canImport(FoundationXML)
private import class FoundationXML.XMLParser
private import protocol FoundationXML.XMLParserDelegate
#else
public import class Foundation.XMLParser
public import protocol Foundation.XMLParserDelegate
#endif

extension XMLElement {
    /// Tries to parse the given data as XML.
    /// - Parameter data: The XML data to parse.
    /// - Returns: The parsed element.
    /// - Throws: Any error reported by ``Foundation/XMLParser``.
    ///           ``XMLElement/UnknownParsingError`` if parsing failed but no error was reported.
    ///           ``XMLElement/MissingRootElementError`` if parsing succeeded but no root element was parsed.
    public static func parse(_ data: Data) throws -> Self {
        let parser = XMLParser(data: data)
        let delegate = ParserDelegate()
        parser.delegate = delegate
        defer { parser.delegate = nil }
        guard parser.parse() else { throw parser.parserError ?? UnknownParsingError() }
        guard let parsedRoot = delegate.parsedRoot else { throw MissingRootElementError() }
        return parsedRoot
    }

    /// Tries to parse the given string as XML.
    /// - Parameter string: The XML string to parse.
    /// - Returns: The parsed element.
    /// - Throws: Any error reported by ``Foundation/XMLParser``.
    ///           ``XMLElement/UnknownParsingError`` if parsing failed but no error was reported.
    ///           ``XMLElement/MissingRootElementError`` if parsing succeeded but no root element was parsed.
    /// - SeeAlso: ``XMLElement/parse(_:)-3057l``
    @inlinable
    public static func parse(_ string: some StringProtocol) throws -> Self {
        try parse(Data(string.utf8))
    }
}

extension ExpressibleByXMLElement {
    /// Tries to parse the given XML data and convert the resulting element.
    /// - Parameter data: The XML data to parse.
    /// - Throws: Any error thrown by ``XMLElement/parse(_:)-3057l`` or ``ExpressibleByXMLElement/init(xml:)`` of the receiver.
    /// - Returns: The parsed element converted to the receiving type.
    /// - SeeAlso: ``XMLElement/parse(_:)-3057l``.
    @inlinable
    public static func parsedFromXML(_ data: Data) throws -> Self {
        try XMLElement.parse(data).converted(to: Self.self)
    }

    /// Tries to parse the given XML string and convert the resulting element.
    /// - Parameter string: The XML string to parse.
    /// - Throws: Any error thrown by ``XMLElement/parse(_:)-3lced`` or ``ExpressibleByXMLElement/init(xml:)`` of the receiver.
    /// - Returns: The parsed element converted to the receiving type.
    /// - SeeAlso: ``XMLElement/parse(_:)-3lced``.
    @inlinable
    public static func parsedFromXML(_ string: some StringProtocol) throws -> Self {
        try XMLElement.parse(string).converted(to: Self.self)
    }
}

// MARK: - Parsing Errors
extension XMLElement {
    /// Describes an unknown error.
    /// Used if parsing fails, but the `XMLParser` of Foundation does not report an error.
    public struct UnknownParsingError: Error, CustomStringConvertible {
        public var description: String { "An unknown parsing error occurred!" }
    }

    /// Describes a failure that caused no element to be parsed.
    /// Used if parsing succeeds, but no element was parsed.
    public struct MissingRootElementError: Error, CustomStringConvertible {
        public var description: String {
            "Parsing did not yield an element! Please check that the XML is valid!"
        }
    }
}

// MARK: - Delegate
extension XMLElement {
    fileprivate final class ParserDelegate: NSObject, XMLParserDelegate {
        fileprivate var parsedRoot: XMLElement?
        private var elementStack = Array<XMLElement>()

        private func stripTrailingNewlinesAndWhitespaces(of element: inout XMLElement) {
            guard !element.content.isEmpty,
                  case let idx = element.content.indexBeforeEndIndex,
                  case .string(let str) = element.content[idx]
            else { return }
            let stripped = str.dropLast(str.reversed().prefix(while: { $0.isWhitespace || $0.isNewline }).count)
            element.content[idx] = .string(String(stripped))
        }

        private func _parserDidStartElement(named elementName: String,
                                            namespaceURI: String?,
                                            qualifiedName qName: String?,
                                            attributes attributeDict: Dictionary<String, String>) {
            elementStack.append(.init(name: .init(rawValue: elementName), attributes: attributeDict.asAttributes))
        }

        private func _parserDidEndElement(named elementName: String,
                                          namespaceURI: String?,
                                          qualifiedName qName: String?) {
            guard var lastElem = elementStack.popLast() else { return } // This shouldn't happen
            stripTrailingNewlinesAndWhitespaces(of: &lastElem)
            if var parent = elementStack.popLast() {
                stripTrailingNewlinesAndWhitespaces(of: &parent)
                parent.appendElement(lastElem)
                elementStack.append(parent)
            } else {
                parsedRoot = lastElem
            }
        }

        private func _parserFoundCharacters(_ string: String) {
            // We currently ignore whitespace only text. Let's hope we never miss something important this way. :)
            guard !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  var currentElem = elementStack.popLast()
            else { return }
            if currentElem.content.isEmpty || currentElem.content.last?.isElement == true {
                // For first strings (either after elements or generally first content), we strip leading newlines.
                let leftTrimmed = string.drop(while: { $0.isNewline || $0.isWhitespace })
                currentElem.content.append(.string(String(leftTrimmed)))
            } else {
                // We must not trim whitespaces here!
                // For e.g. "One &amp; Two", the parser passes us "One ", "&", " Two".
                // Cleanup of the string will be taken care of at the end of the element.
                currentElem.appendString(string)
            }
            elementStack.append(currentElem)
        }

        private func parserFoundCDATA(_ cDataBlock: Data) {
            guard var currentElem = elementStack.popLast() else { return } // This shouldn't happen
            // TODO: Do we need to support CDATA seperately?
            currentElem.appendString(String(decoding: cDataBlock, as: UTF8.self))
            elementStack.append(currentElem)
        }

#if canImport(ObjectiveC)
        @objc dynamic func parser(_ parser: XMLParser,
                                  didStartElement elementName: String,
                                  namespaceURI: String?,
                                  qualifiedName qName: String?,
                                  attributes attributeDict: Dictionary<String, String> = [:]) {
            _parserDidStartElement(named: elementName,
                                   namespaceURI: namespaceURI,
                                   qualifiedName: qName,
                                   attributes: attributeDict)
        }

        @objc dynamic func parser(_ parser: XMLParser,
                                  didEndElement elementName: String,
                                  namespaceURI: String?,
                                  qualifiedName qName: String?) {
            _parserDidEndElement(named: elementName, namespaceURI: namespaceURI, qualifiedName: qName)
        }

        @objc dynamic func parser(_ parser: XMLParser, foundCharacters string: String) {
            _parserFoundCharacters(string)
        }

        @objc dynamic func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
            parserFoundCDATA(CDATABlock)
        }
#else
        func parser(_ parser: XMLParser,
                    didStartElement elementName: String,
                    namespaceURI: String?,
                    qualifiedName qName: String?,
                    attributes attributeDict: Dictionary<String, String> = [:]) {
            _parserDidStartElement(named: elementName,
                                   namespaceURI: namespaceURI,
                                   qualifiedName: qName,
                                   attributes: attributeDict)
        }

        func parser(_ parser: XMLParser,
                    didEndElement elementName: String,
                    namespaceURI: String?,
                    qualifiedName qName: String?) {
            _parserDidEndElement(named: elementName, namespaceURI: namespaceURI, qualifiedName: qName)
        }

        func parser(_ parser: XMLParser, foundCharacters string: String) {
            _parserFoundCharacters(string)
        }

        func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
            parserFoundCDATA(CDATABlock)
        }
#endif
    }
}

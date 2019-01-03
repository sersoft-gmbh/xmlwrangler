import struct Foundation.Data
import class Foundation.NSObject
import class Foundation.XMLParser
import protocol Foundation.XMLParserDelegate

/// Responsible for parsing XMLs.
public final class Parser: ParserDelegate {
   private let xmlParser: XMLParser
   private let delegate = Delegate()

   private var parsedRoot: Element?
   private var elementStack: [Element] = []

   /// Creates a new instance using the given `Data`.
   ///
   /// - Parameter data: The XML data to parse.
   public init(data: Data) {
      xmlParser = XMLParser(data: data)
      delegate.delegate = self
      xmlParser.delegate = delegate
   }

   /// Creates a new instance using the given string.
   ///
   /// - Parameter string: An XML string.
   @inlinable
   public convenience init(string: String) {
      self.init(data: Data(string.utf8))
   }

   /// Tries to parse the associated XML data. The parsing is only performed once.
   ///
   /// - Returns: The parsed element.
   /// - Throws: Any error reported by `Foundation.XMLParser`.
   public func parse() throws -> Element {
      // We only parse things once...
      if let object = parsedRoot { return object }

      if !xmlParser.parse() {
         throw xmlParser.parserError ?? UnknownError()
      }
      guard let obj = parsedRoot else { fatalError("Wow, we parsed successfully, but have no object?!") }
      return obj
   }

   // MARK: - ParserDelegate
   fileprivate func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
      let elem = Element(name: .init(rawValue: elementName), attributes: attributeDict.asAttributes)
      elementStack.append(elem)
   }

   fileprivate func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
      guard let lastElem = elementStack.popLast() else { return } // This shouldn't happen
      if var parent = elementStack.popLast() {
         parent.append(object: lastElem)
         elementStack.append(parent)
      } else {
         parsedRoot = lastElem
      }
   }

   fileprivate func parser(_ parser: XMLParser, foundCharacters string: String) {
      // We currently ignore whitespace only text. Let's hope we never miss something important this way. :)
      let strippedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !strippedString.isEmpty else { return }
      guard var currentElem = elementStack.popLast() else { return }
      currentElem.append(string: strippedString)
      elementStack.append(currentElem)
   }

   fileprivate func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
      guard var currentElem = elementStack.popLast() else { return }
      // TODO: Do we need to support CDATA seperately?
      currentElem.append(string: String(decoding: CDATABlock, as: UTF8.self))
      elementStack.append(currentElem)
   }
}

// MARK: - Unknown Parsing Error
public extension Parser {
   /// Describes an unknown error.
   /// Used if parsing fails, but the XMLParser of Foundation does not report an error.
   public struct UnknownError: Error, CustomStringConvertible {
      public var description: String { return "An unknown parsing error occurred!" }
   }
}

// MARK: - Delegate forwarding
fileprivate protocol ParserDelegate: class {
   func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String])
   func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
   func parser(_ parser: XMLParser, foundCharacters string: String)
   func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data)
//   func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error)
//   func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error)
}

fileprivate extension Parser {
   fileprivate final class Delegate: NSObject, XMLParserDelegate {
      weak var delegate: ParserDelegate?

      #if !os(Linux)
      @objc dynamic func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
         delegate?.parser(parser, didStartElement: elementName, namespaceURI: namespaceURI, qualifiedName: qName, attributes: attributeDict)
      }

      @objc dynamic func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
         delegate?.parser(parser, didEndElement: elementName, namespaceURI: namespaceURI, qualifiedName: qName)
      }

      @objc dynamic func parser(_ parser: XMLParser, foundCharacters string: String) {
         delegate?.parser(parser, foundCharacters: string)
      }

      @objc dynamic func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
         delegate?.parser(parser, foundCDATA: CDATABlock)
      }
      #else
      func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
         delegate?.parser(parser, didStartElement: elementName, namespaceURI: namespaceURI, qualifiedName: qName, attributes: attributeDict)
      }

      func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
         delegate?.parser(parser, didEndElement: elementName, namespaceURI: namespaceURI, qualifiedName: qName)
      }

      func parser(_ parser: XMLParser, foundCharacters string: String) {
         delegate?.parser(parser, foundCharacters: string)
      }

      func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
         delegate?.parser(parser, foundCDATA: CDATABlock)
      }
      #endif
   }
}

fileprivate extension Dictionary where Key == XMLWrangler.Element.AttributeKey.RawValue {
    var asAttributes: [XMLWrangler.Element.AttributeKey: Value] {
        return .init(uniqueKeysWithValues: map { (.init(rawValue: $0.key), $0.value) })
    }
}

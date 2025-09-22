import Testing
@testable import XMLWrangler

extension XMLElementTests {
    @Suite
    struct ContentTests {
        private typealias Content = XWElement.Content

        @Test
        func contentElementDescriptions() {
            let strPart = Content.Element.string("abc")
            let elemPart = Content.Element.element(XWElement(name: "test"))
            #expect(strPart.description == "StringPart(abc)")
            #expect(strPart.debugDescription == "StringPart { abc }")
            #expect(elemPart.description == "Element(test)")
            #expect(elemPart.debugDescription == "Element {\n\(XWElement(name: "test").debugDescription)\n}")
        }

        @Test
        func contentElementInitializers() {
            let strPart: Content.Element = "str"
            let elemPart: Content.Element = .init(xml: XWElement(name: "abc"))
            #expect(strPart == .string("str"))
            #expect(elemPart == .element(XWElement(name: "abc")))
        }

        @Test
        func initialization() {
            #expect(Content().storage.isEmpty)
            #expect(([.string("string"), .element(.init(name: "elem"))] as Content).storage
                    ==
                    [.string("string"), .element(.init(name: "elem"))])
        }

        @Test
        func descriptions() {
            let content: Content = ["strContent", .element(.init(name: "test-element"))]
            #expect(content.description == content.storage.description)
            #expect(content.debugDescription == content.storage.debugDescription)
        }

        @Test
        func mutableCollectionConformance() {
            var content: Content = [.string("string"), .element(.init(name: "elem"))]
            #expect(content.startIndex == content.storage.startIndex)
            #expect(content.endIndex == content.storage.endIndex)
            #expect(content.underestimatedCount == content.storage.underestimatedCount)
            #expect(content.count == content.storage.count)
            #expect(content.isEmpty == content.storage.isEmpty)
            #expect(content.isEmpty == content.storage.isEmpty)
            #expect(content.index(after: content.startIndex) == content.storage.index(after: content.storage.startIndex))
            #expect(content[content.startIndex] == content.storage[content.storage.startIndex])
            content[content.startIndex] = .element(.init(name: "otherElem"))
            #expect(content.storage[content.storage.startIndex] == .element(.init(name: "otherElem")))
        }

        @Test
        func bidirectionalCollectionConformance() {
            let content: Content = ["bidi"]
            #expect(content.index(before: content.endIndex) == content.storage.index(before: content.storage.endIndex))
        }

        @Test
        func randomAccessCollectionConformance() {
            let content: Content = ["random", "access", "collection"]
            #expect(content.index(content.startIndex, offsetBy: 2) == content.storage.index(content.storage.startIndex, offsetBy: 2))
            #expect(content.distance(from: content.startIndex, to: content.endIndex)
                    ==
                    content.storage.distance(from: content.storage.startIndex, to: content.storage.endIndex))
        }

        @Test
        func rangeReplacableCollectionConformance() {
            var content: Content = ["range", "replacable", "collection"]
            var storage = content.storage
            content.replaceSubrange(0..<2, with: ["r", "r"])
            storage.replaceSubrange(0..<2, with: ["r", "r"])
            #expect(content.storage == storage)
        }

        @Test
        func expressibleByXMLElementConformance() {
            #expect(Content(xml: .init(name: "elem")).storage == [.element(.init(name: "elem"))])
        }

        @Test
        func expressibleByStringLiteralConformance() {
            #expect(("test" as Content).storage == [.string("test")])
        }

        @Test
        func expressibleByStringInterpolationConformance() {
            struct Convertible: XMLElementConvertible {
                let xml: XWElement
            }

            let elem1 = XWElement(name: "testElement")
            let elem2 = XWElement(name: "test2", elements: elem1)
            let contents: Content.Storage = [.string("some string"), .element(elem1)]
            let testString = "some_text"
            let c1: Content = "literal\(elem1)\(testString)convertible:\(Convertible(xml: elem2))"
            #expect(c1.storage == [.string("literal"), .element(elem1), .string(testString + "convertible:"), .element(elem2)])
            let c2: Content = "whatever \(contents) empty: \(contentOf: elem1)"
            #expect(c2.storage == [.string("whatever some string"), .element(elem1), .string(" empty: ")])
            let c3: Content = "\(.element(elem1), .string("let's see"))"
            #expect(c3.storage == [.element(elem1), .string("let's see")])
            let c4: Content = "some text \(c3) and more text"
            #expect(c4.storage == [.string("some text "), .element(elem1), .string("let's see and more text")])
            let c5: Content = "contents: \(contentOf: elem2) here"
            #expect(c5.storage == [.string("contents: "), .element(elem1), .string(" here")])
        }
    }
}

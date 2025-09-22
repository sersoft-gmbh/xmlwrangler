import Testing
import XMLWrangler

@Suite
struct XMLContentBuilderTests {
    fileprivate struct Convertible: XMLElementConvertible {
        let xml: XWElement
    }

    @Test
    func builderMethods() {
        #expect(XMLContentBuilder.buildExpression(.string("test")) == [.string("test")])
        #expect(XMLContentBuilder.buildExpression("test") == [.string("test")])
        #expect(XMLContentBuilder.buildExpression(XWElement(name: "test")) == [.element(XWElement(name: "test"))])
        #expect(XMLContentBuilder.buildExpression(Convertible(xml: XWElement(name: "test"))) == [.element(XWElement(name: "test"))])

        #expect(XMLContentBuilder.buildBlock() == [])
        #expect(XMLContentBuilder.buildBlock([.element(XWElement(name: "test"))]) == [.element(XWElement(name: "test"))])
        #expect(XMLContentBuilder.buildBlock([.element(XWElement(name: "test"))], [.string("test")])
                ==
                [.element(XWElement(name: "test")), .string("test")])

        #expect(XMLContentBuilder.buildOptional(nil) == [])
        #expect(XMLContentBuilder.buildOptional([.string("test")]) == [.string("test")])

        #expect(XMLContentBuilder.buildEither(first: [.string("test1")]) == [.string("test1")])
        #expect(XMLContentBuilder.buildEither(second: [.string("test1")]) == [.string("test1")])

        #expect(XMLContentBuilder.buildArray([[.element(XWElement(name: "test"))], [.string("test")]])
                ==
                [.element(XWElement(name: "test")), .string("test")])

        #expect(XMLContentBuilder.buildFinalResult([.element(XWElement(name: "test")), .string("test1"), .string("test2")])
                ==
                [.element(XWElement(name: "test")), .string("test1\ntest2")])
    }

    @Test
    func building() {
        enum Kind: CaseIterable {
            case a, b, c
        }

        let bool = true
        let kind = Kind.a
        let int = 5

        let root = XWElement(name: "root") {
            XWElement(name: "inner1") {
                "String line 1 in inner1"
                "String line 2 in inner1"
            }
            if bool {
                XWElement(name: "inner2")
                "String line 1"
                "String line 2"
            }
            "Another string line"
            if bool {
                XWElement(name: "if-true")
                "String line in true"
                XWElement(name: "if-true2")
            } else {
                XWElement(name: "if-false")
                "String line in false"
            }
            switch kind {
            case .a:
                XWElement(name: "kind-a")
                "String line in kind a"
            case .b: XWElement(name: "kind-b")
            case .c:
                XWElement(name: "kind-c") {
                    "Some string content of kind-c"
                }
            }
            "Element Loop"
            for i in 0..<int {
                XWElement(name: .init(rawValue: "loop-\(i)"))
            }
            "String Loop"
            for i in 0..<int {
                "Loop line \(i + 1)"
            }
        }

        let expectedElement = XWElement(name: "root", content: [
            .element(XWElement(name: "inner1", content: "String line 1 in inner1\nString line 2 in inner1")),
            .element(XWElement(name: "inner2")),
            .string("String line 1\nString line 2\nAnother string line"),
            .element(XWElement(name: "if-true")),
            .string("String line in true"),
            .element(XWElement(name: "if-true2")),
            .element(XWElement(name: "kind-a")),
            .string("String line in kind a\nElement Loop"),
                .element(XWElement(name: "loop-0")),
                .element(XWElement(name: "loop-1")),
                .element(XWElement(name: "loop-2")),
                .element(XWElement(name: "loop-3")),
                .element(XWElement(name: "loop-4")),
                .string("String Loop\nLoop line 1\nLoop line 2\nLoop line 3\nLoop line 4\nLoop line 5"),
        ])

        #expect(root == expectedElement)
    }
}

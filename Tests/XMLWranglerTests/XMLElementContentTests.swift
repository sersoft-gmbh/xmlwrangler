import Testing
@testable import XMLWrangler

@Suite
struct XMLElementContentTests {
    @Test
    func expressibleByStringLiteral() {
        let element: XWElement.Content.Element = "test"
        #expect(element == .string("test"))
    }

    @Test
    func appendingString() {
        var content: XWElement.Content = []
        var content2: XWElement.Content = ["hello"]

        content.appendString("_this")
        content2.appendString(" world")

        #expect(content == [.string("_this")])
        #expect(content2 == [.string("hello world")])
    }

    @Test
    func appendingObject() {
        var content: XWElement.Content = []
        let child = XWElement(name: "_this")

        content.appendElement(child)

        #expect(content == [.element(child)])
    }

    @Test
    func appendingContentOfSequence() {
        var content: XWElement.Content = []
        let child1 = XWElement(name: "one1")
        let child2 = XWElement(name: "two2")
        let child3 = XWElement(name: "three3")

        content.append(contentsOf: [child1, child2, child3])

        #expect(content == [.element(child1), .element(child2), .element(child3)])
    }

    @Test
    func appendingElements() {
        var content: XWElement.Content = []
        let child1 = XWElement(name: "abc1")
        let child2 = XWElement(name: "def2")
        let child3 = XWElement(name: "ghi3")

        content.appendElements(child1, child2, child3)

        #expect(content == [.element(child1), .element(child2), .element(child3)])
    }

    @Test
    func compression() {
        var content1: XWElement.Content = [
            .string("ABC"),
            .string("DEF"),
            .element(XWElement(name: "elem1")),
            .element(XWElement(name: "elem2")),
            .string("GHI"),
            .element(XWElement(name: "elem3")),
            .string("JKL"),
            .string("MNO"),
        ]
        let expectedContent1: XWElement.Content = [
            .string("ABCDEF"),
            .element(XWElement(name: "elem1")),
            .element(XWElement(name: "elem2")),
            .string("GHI"),
            .element(XWElement(name: "elem3")),
            .string("JKLMNO"),
        ]

        var content2: XWElement.Content = [
            .string("AB"),
            .string("CD"),
            .element(XWElement(name: "e1")),
            .element(XWElement(name: "e2")),
            .element(XWElement(name: "e3")),
            .string("EF"),
            .element(XWElement(name: "e4")),
            .element(XWElement(name: "e5")),
            .string("GH"),
            .string("IJ"),
            .string("KL"),
            .element(XWElement(name: "e6")),
            .element(XWElement(name: "e7")),
        ]
        let expectedContent2: XWElement.Content = [
            .string("ABCD"),
            .element(XWElement(name: "e1")),
            .element(XWElement(name: "e2")),
            .element(XWElement(name: "e3")),
            .string("EF"),
            .element(XWElement(name: "e4")),
            .element(XWElement(name: "e5")),
            .string("GHIJKL"),
            .element(XWElement(name: "e6")),
            .element(XWElement(name: "e7")),
        ]

        let compressed1 = content1.compressed()
        content1.compress()
        let compressed2 = content2.compressed()
        content2.compress()

        #expect(content1 == expectedContent1)
        #expect(content2 == expectedContent2)
        #expect(content1 == compressed1)
        #expect(content2 == compressed2)
    }

    @Test
    func internalHelpers() {
        let strContent = XWElement.Content.Element.string("ABC")
        let elemtContent = XWElement.Content.Element.element(XWElement(name: "some_element"))

        #expect(strContent.isString)
        #expect(!strContent.isElement)
        #expect(strContent.string == "ABC")
        #expect(strContent.element == nil)
        #expect(!elemtContent.isString)
        #expect(elemtContent.isElement)
        #expect(elemtContent.string == nil)
        #expect(elemtContent.element == XWElement(name: "some_element"))
    }
}

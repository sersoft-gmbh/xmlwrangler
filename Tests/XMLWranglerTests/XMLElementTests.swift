import Testing
import XMLWrangler

@Suite
struct XMLElementTests {
    @Test
    func initialization() {
        let allDefaults = XWElement(name: "test")
        let withAttrs = XWElement(name: "test", attributes: ["test": "test"])
        let withContentNormal = XWElement(name: "test", attributes: ["test": "test"], content: ["test"])
        let withContentVariadic = XWElement(name: "test", attributes: ["test": "test"], content: "test")
        let withContentVariadicNoAttrs = XWElement(name: "test", content: .string("test"))
        let withElements = XWElement(name: "test", attributes: ["test": "test"], elements: [XWElement(name: "test")])
        let withElementsNoAttrs = XWElement(name: "test", elements: [XWElement(name: "test")])
        let withVariadicElements = XWElement(name: "test", attributes: ["test": "test"], elements: XWElement(name: "test"))
        let withVariadicElementsNoAttrs = XWElement(name: "test", elements: XWElement(name: "test"))
        let withStringContent = XWElement(name: "test", attributes: ["test": "test"], stringContent: "test")
        let withStringContentNoAttrs = XWElement(name: "test", stringContent: "test")

        #expect(allDefaults.name == "test")
        #expect(allDefaults.attributes.isEmpty)
        #expect(allDefaults.content.isEmpty)

        #expect(withAttrs.name == "test")
        #expect(withAttrs.attributes == ["test": "test"])
        #expect(withAttrs.content.isEmpty)

        #expect(withContentNormal.name == "test")
        #expect(withContentNormal.attributes == ["test": "test"])
        #expect(withContentNormal.content == [.string("test")])

        #expect(withContentVariadic.name == "test")
        #expect(withContentVariadic.attributes == ["test": "test"])
        #expect(withContentVariadic.content == [.string("test")])
        #expect(withContentVariadicNoAttrs.name == "test")
        #expect(withContentVariadicNoAttrs.attributes.isEmpty)
        #expect(withContentVariadicNoAttrs.content == [.string("test")])

        #expect(withElements.name == "test")
        #expect(withElements.attributes == ["test": "test"])
        #expect(withElements.content == [.element(XWElement(name: "test"))])
        #expect(withElementsNoAttrs.name == "test")
        #expect(withElementsNoAttrs.attributes.isEmpty)
        #expect(withElementsNoAttrs.content == [.element(XWElement(name: "test"))])

        #expect(withVariadicElements.name == "test")
        #expect(withVariadicElements.attributes == ["test": "test"])
        #expect(withVariadicElements.content == [.element(XWElement(name: "test"))])
        #expect(withVariadicElementsNoAttrs.name == "test")
        #expect(withVariadicElementsNoAttrs.attributes.isEmpty)
        #expect(withVariadicElementsNoAttrs.content == [.element(XWElement(name: "test"))])

        #expect(withStringContent.name == "test")
        #expect(withStringContent.attributes == ["test": "test"])
        #expect(withStringContent.content == [.string("test")])
        #expect(withStringContentNoAttrs.name == "test")
        #expect(withStringContentNoAttrs.attributes.isEmpty)
        #expect(withStringContentNoAttrs.content == [.string("test")])
    }

    @Test
    func identifier() {
        let element = XWElement(name: "test")
        #expect(element.id == element.name)
    }

    @Test
    func description() {
        let element = XWElement(name: "abc")
        #expect(element.description
                ==
                "XMLElement '\(element.name)' { \(element.attributes.count) attribute(s), \(element.content.count) content element(s) }")
    }

    @Test
    func debugDescription() {
        let element = XWElement(name: "abc")
        #expect(element.debugDescription
                ==
                """
                XMLElement '\(element.name.debugDescription)' {
                attributes: \(element.attributes.debugDescription)
                contents: \(element.content.debugDescription)
                }
                """)
    }

    @Test
    func xmlElementRepresentableCoformance() {
        let element = XWElement(name: "conv-test")
        #expect(XWElement(xml: element) == element)
        #expect(element.xml == element)
    }
}

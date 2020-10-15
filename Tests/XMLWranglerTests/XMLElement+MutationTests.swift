import XCTest
@testable import XMLWrangler

fileprivate extension XWElement.Content.Element {
    var _element: XWElement! {
        get { element }
        set { self = .element(newValue) }
    }
}

final class XMLElement_MutationTests: XCTestCase {
    private var sut: XWElement!
    
    override func setUp() {
        super.setUp()
        sut = XWElement(name: "Root",
                        elements: [
                            XWElement(name: "Child1", attributes: ["some": "value"], elements: XWElement(name: "Child1.1")),
                            XWElement(name: "Child2", elements: XWElement(name: "Child2.1", attributes: [.init("other"): "value"])),
                        ])
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testAppendingString() {
        var element = XWElement(name: "test")
        var element2 = XWElement(name: "test2", stringContent: "hello")

        element.append(string: "_this")
        element2.append(string: " world")

        XCTAssertEqual(element.content, [.string("_this")])
        XCTAssertEqual(element2.content, [.string("hello world")])
    }

    func testAppendingElement() {
        var element = XWElement(name: "test")
        let child = XWElement(name: "_this")

        element.append(element: child)

        XCTAssertEqual(element.content, [.element(child)])
    }

    func testAppendingContentOfSequence() {
        var element = XWElement(name: "test")
        let child1 = XWElement(name: "_this1")
        let child2 = XWElement(name: "_this2")
        let child3 = XWElement(name: "_this3")

        element.append(contentsOf: [child1, child2, child3])

        XCTAssertEqual(element.content, [.element(child1), .element(child2), .element(child3)])
    }

    func testAppendingElements() {
        var element = XWElement(name: "test")
        let child1 = XWElement(name: "_this1")
        let child2 = XWElement(name: "_this2")
        let child3 = XWElement(name: "_this3")

        element.append(elements: child1, child2, child3)

        XCTAssertEqual(element.content, [.element(child1), .element(child2), .element(child3)])
    }
    
    func testMutatingAccessToElementAtInvalidPathThrows() {
        XCTAssertThrowsError(try sut.withMutatingAccess(toElementAt: "Child1", "InexistentChild", do: { _ in XCTFail("Should not be called!") })) {
            XCTAssert($0, is: .missingChild(element: sut.content[0]._element, childName: "InexistentChild"))
        }
    }
    
    func testMutatingAccessToElementAtPath() throws {
        var expectedResult: XWElement = sut
        expectedResult.content[0]._element.content[0]._element.append(element: XWElement(name: "Test"))
        try sut.withMutatingAccess(toElementAt: ["Child1", "Child1.1"], do: { $0.append(element: XWElement(name: "Test")) })
        XCTAssertEqual(sut, expectedResult)
    }
    
    func testMutatingAccessToElementAtVariadicPath() throws {
        var expectedResult: XWElement = sut
        expectedResult.content[0]._element.content[0]._element.append(element: XWElement(name: "Test"))
        try sut.withMutatingAccess(toElementAt: "Child1", "Child1.1", do: { $0.append(element: XWElement(name: "Test")) })
        XCTAssertEqual(sut, expectedResult)
    }
    
    func testReplacingElementAtPath() throws {
        let oldElement = sut.content[0]._element.content[0]._element
        var expectedResult: XWElement = sut
        expectedResult.content[0]._element.content[0]._element = XWElement(name: "Test")
        let replacedElement = try sut.replace(elementAt: ["Child1", "Child1.1"], with: XWElement(name: "Test"))
        XCTAssertEqual(sut, expectedResult)
        XCTAssertEqual(replacedElement, oldElement)
    }
    
    func testReplacingElementAtVariadicPath() throws {
        let oldElement = sut.content[0]._element.content[0]._element
        var expectedResult: XWElement = sut
        expectedResult.content[0]._element.content[0]._element = XWElement(name: "Test")
        let replacedElement = try sut.replace(elementAt: "Child1", "Child1.1", with: XWElement(name: "Test"))
        XCTAssertEqual(sut, expectedResult)
        XCTAssertEqual(replacedElement, oldElement)
    }
    
    func testRemovingElementAtEmptyPath() {
        XCTAssertNil(try sut.remove(elementAt: []))
    }
    
    func testRemovingInexistentElementAtPath() {
        XCTAssertNil(try sut.remove(elementAt: ["Child1", "DoesNotExist"]))
    }
    
    func testRemovingElementAtPath() throws {
        var expectedResult: XWElement = sut
        let expectedReturnValue = expectedResult.content[0]._element.content.remove(at: 0)._element
        let removed = try sut.remove(elementAt: ["Child1", "Child1.1"])
        XCTAssertEqual(sut, expectedResult)
        XCTAssertEqual(removed, expectedReturnValue)
    }
    
    func testRemovingElementAtVariadicPath() throws {
        var expectedResult: XWElement = sut
        let expectedReturnValue = expectedResult.content[0]._element.content.remove(at: 0)._element
        let removed = try sut.remove(elementAt: "Child1", "Child1.1")
        XCTAssertEqual(sut, expectedResult)
        XCTAssertEqual(removed, expectedReturnValue)
    }
}

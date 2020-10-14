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
    
    func testMutatingAccessToElementAtInvalidPathThrows() {
        XCTAssertThrowsError(try sut.withMutatingAccess(toElementAt: "Child1", "InexistentChild", do: { _ in XCTFail("Should not be called!") })) {
            XCTAssert($0, is: .missingChild(element: sut.content[0]._element, childElementName: "InexistentChild"))
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
        var expectedResult: XWElement = sut
        expectedResult.content[0]._element.content[0]._element = XWElement(name: "Test")
        try sut.replace(elementAt: ["Child1", "Child1.1"], with: XWElement(name: "Test"))
        XCTAssertEqual(sut, expectedResult)
    }
    
    func testReplacingElementAtVariadicPath() throws {
        var expectedResult: XWElement = sut
        expectedResult.content[0]._element.content[0]._element = XWElement(name: "Test")
        try sut.replace(elementAt: "Child1", "Child1.1", with: XWElement(name: "Test"))
        XCTAssertEqual(sut, expectedResult)
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

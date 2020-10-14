import XCTest
@testable import XMLWrangler

final class XMLElementTests: XCTestCase {
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
}

import Testing
@testable import XMLWrangler

fileprivate extension XWElement.Content.Element {
    var _element: XWElement! {
        get { element }
        set { self = .element(newValue) }
    }
}

extension XMLElementTests {
    @Suite
    struct MutationTests {
        private var sut = XWElement(
            name: "Root",
            elements: [
                XWElement(name: "Child1",
                          attributes: ["some": "value"],
                          elements: XWElement(name: "Child1.1")),
                XWElement(name: "Child2",
                          elements: XWElement(name: "Child2.1",
                                              attributes: [.init("other"): "value"])),
            ]
        )

        @Test
        func appendingString() {
            var element = XWElement(name: "s")
            var element2 = XWElement(name: "test2", stringContent: "hello")

            element.appendString("_this")
            element2.appendString(" world")

            #expect(element.content == [.string("_this")])
            #expect(element2.content == [.string("hello world")])
        }

        @Test
        func appendingElement() {
            var element = XWElement(name: "x")
            let child = XWElement(name: "_this")
            element.appendElement(child)
            #expect(element.content == [.element(child)])
        }

        @Test
        func appendingElementConvertible() {
            struct Convertible: XMLElementConvertible {
                let xml: XWElement
            }

            var element = XWElement(name: "base")
            let child = XWElement(name: "child")
            element.append(elementOf: Convertible(xml: child))
            #expect(element.content == [.element(child)])
        }

        @Test
        func appendingContentOfSequence() {
            var element = XWElement(name: "a")
            let child1 = XWElement(name: "_this1")
            let child2 = XWElement(name: "_this2")
            let child3 = XWElement(name: "_this3")

            element.append(contentsOf: [child1, child2, child3])

            #expect(element.content == [.element(child1), .element(child2), .element(child3)])
        }

        @Test
        func appendingElements() {
            var element = XWElement(name: "b")
            let child1 = XWElement(name: "_this1")
            let child2 = XWElement(name: "_this2")
            let child3 = XWElement(name: "_this3")

            element.appendElements(child1, child2, child3)

            #expect(element.content == [.element(child1), .element(child2), .element(child3)])
        }

        @Test
        mutating func mutatingAccessToElementAtInvalidPathThrows() {
            struct InvalidExecutionError: Error {}
#if swift(>=6.1)
            let error = #expect(throws: (any Error).self) {
                try sut.withMutatingAccess(toElementAt: "Child1", "InexistentChild",
                                           do: { _ in
                    throw InvalidExecutionError()
                })
            }
#else
            let error: (any Error)?
            do {
                try sut.withMutatingAccess(toElementAt: "Child1", "InexistentChild",
                                           do: { _ in
                    throw InvalidExecutionError()
                })
                error = nil
            } catch let caughtError {
                error = caughtError
            }
#endif
            #expect(error is XWElement.LookupError)
            #expect(error as? XWElement.LookupError == .missingChild(element: sut.content[0]._element, childName: "InexistentChild"))
        }

        @Test
        mutating func mutatingAccessToElementAtPath() throws {
            var expectedResult: XWElement = sut
            expectedResult.content[0]._element.content[0]._element.appendElement(XWElement(name: "TestMutating"))
            try sut.withMutatingAccess(toElementAt: ["Child1", "Child1.1"],
                                       do: { $0.appendElement(XWElement(name: "TestMutating")) })
            #expect(sut == expectedResult)
        }

        @Test
        mutating func mutatingAccessToElementAtVariadicPath() throws {
            var expectedResult: XWElement = sut
            expectedResult.content[0]._element.content[0]._element.appendElement(XWElement(name: "TestVariadicMutating"))
            try sut.withMutatingAccess(toElementAt: "Child1", "Child1.1",
                                       do: { $0.appendElement(XWElement(name: "TestVariadicMutating")) })
            #expect(sut == expectedResult)
        }

        @Test
        mutating func replacingElementAtPath() throws {
            let oldElement = sut.content[0]._element.content[0]._element
            var expectedResult: XWElement = sut
            expectedResult.content[0]._element.content[0]._element = XWElement(name: "Test")
            let replacedElement = try sut.replace(elementAt: ["Child1", "Child1.1"], with: XWElement(name: "Test"))
            #expect(sut == expectedResult)
            #expect(replacedElement == oldElement)
        }

        @Test
        mutating func replacingElementAtVariadicPath() throws {
            let oldElement = sut.content[0]._element.content[0]._element
            var expectedResult: XWElement = sut
            expectedResult.content[0]._element.content[0]._element = XWElement(name: "TestVariadic")
            let replacedElement = try sut.replace(elementAt: "Child1", "Child1.1", with: XWElement(name: "TestVariadic"))
            #expect(sut == expectedResult)
            #expect(replacedElement == oldElement)
        }

        @Test
        mutating func removingElementAtEmptyPath() throws {
            #expect(try sut.remove(elementAt: []) == nil)
        }

        @Test
        mutating func removingInexistentElementAtPath() throws {
            #expect(try sut.remove(elementAt: ["Child1", "DoesNotExist"]) == nil)
        }

        @Test
        mutating func removingElementAtPath() throws {
            var expectedResult: XWElement = sut
            let expectedReturnValue = expectedResult.content[0]._element.content.remove(at: 0)._element
            let removed = try sut.remove(elementAt: ["Child1", "Child1.1"])
            #expect(sut == expectedResult)
            #expect(removed == expectedReturnValue)
        }

        @Test
        mutating func removingElementAtVariadicPath() throws {
            var expectedResult: XWElement = sut
            let expectedReturnValue = expectedResult.content[0]._element.content.remove(at: 0)._element
            let removed = try sut.remove(elementAt: "Child1", "Child1.1")
            #expect(sut == expectedResult)
            #expect(removed == expectedReturnValue)
        }
    }
}

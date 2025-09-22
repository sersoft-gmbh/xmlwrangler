import Testing
import XCTest
@testable import XMLWrangler

extension XMLElementContentTests {
    @Suite
    struct LookupTests {
        @Test
        func allElementsAndAllStrings() {
            let content: XWElement.Content = [
                "abc",
                .element(.init(name: "test")),
                "def",
                .element(.init(name: "test2")),
            ]
            #expect(Array(content.allElements) == [.init(name: "test"), .init(name: "test2")])
            #expect(Array(content.allStrings) == ["abc", "def"])
        }

        @Test
        func findingObjectsShallow() {
            let string: XWElement.Content = [.string("testStr")]
            let source: XWElement.Content = [
                .element(XWElement(name: "test")),
                .element(XWElement(name: "no_test_something")),
                .element(XWElement(name: "whatever")),
                .element(XWElement(name: "test")),
                .element(XWElement(name: "is")),
                .element(XWElement(name: "hereNot")),
                .element(XWElement(name: "no_test_something")),
            ]

            let stringResult = string.find(elementsNamed: "something")
            let cannotFind = source.find(elementsNamed: "not_existent")
            let testResult = source.find(elementsNamed: "test")
            let whateverResult = source.find(elementsNamed: "whatever")

            #expect(stringResult.isEmpty)
            #expect(cannotFind.isEmpty)
            #expect(testResult.count == 2)
            #expect(whateverResult.count == 1)
            #expect(testResult == [XWElement(name: "test"), XWElement(name: "test")])
            #expect(whateverResult == [XWElement(name: "whatever")])
        }

        @Test
        func findingFirstObjectShallow() {
            let string: XWElement.Content = [.string("testStr")]
            let source: XWElement.Content = [
                .element(XWElement(name: "test", content: "value")),
                .element(XWElement(name: "test_something")),
                .element(XWElement(name: "whatever")),
                .element(XWElement(name: "test")),
                .element(XWElement(name: "is")),
                .element(XWElement(name: "here")),
                .element(XWElement(name: "test_something")),
            ]

            let stringResult = string.findFirst(elementNamed: "something")
            let cannotFind = source.findFirst(elementNamed: "not_existent")
            let testResult = source.findFirst(elementNamed: "test")
            let whateverResult = source.findFirst(elementNamed: "whatever")

            #expect(stringResult == nil)
            #expect(cannotFind == nil)
            #expect(testResult != nil)
            #expect(whateverResult != nil)
            #expect(testResult?.content == ["value"])
            #expect(whateverResult?.content.isEmpty == true)
        }

        @Test
        func findingLastObjectShallow() {
            let string: XWElement.Content = [.string("testStr")]
            let source: XWElement.Content = [
                .element(XWElement(name: "test")),
                .element(XWElement(name: "test_something")),
                .element(XWElement(name: "whatever")),
                .element(XWElement(name: "test", content: "value")),
                .element(XWElement(name: "is")),
                .element(XWElement(name: "here")),
                .element(XWElement(name: "test_something")),
            ]

            let stringResult = string.findLast(elementNamed: "something")
            let cannotFind = source.findLast(elementNamed: "not_existent")
            let testResult = source.findLast(elementNamed: "test")
            let whateverResult = source.findLast(elementNamed: "whatever")

            #expect(stringResult == nil)
            #expect(cannotFind == nil)
            #expect(testResult != nil)
            #expect(whateverResult != nil)
            #expect(testResult?.content == ["value"])
            #expect(whateverResult?.content.isEmpty == true)
        }

        @Test
        func findingObjectsRecursive() {
            let string: XWElement.Content = [.string("testStr")]
            let source: XWElement.Content = [
                .element(XWElement(name: "test_something",
                                   attributes: ["some": "is"],
                                   elements: XWElement(name: "test", content: "value"))),
                .element(XWElement(name: "test_it")),
                .element(XWElement(name: "is", elements: [
                    XWElement(name: "add", elements: [
                        XWElement(name: "some", elements: [
                            XWElement(name: "deeper"),
                            XWElement(name: "levels", elements: [
                                XWElement(name: "deeper"),
                                XWElement(name: "can this work"),
                                XWElement(name: "whatever"),
                            ]),
                        ]),
                        XWElement(name: "test"),
                        XWElement(name: "deeper"),
                    ]),
                    XWElement(name: "deeper"),
                ])),
                .element(XWElement(name: "here")),
                .element(XWElement(name: "test_something")),
            ]

            let stringResult = string.find(elementsNamed: "something", recursive: true)
            let cannotFind = source.find(elementsNamed: "not_existent", recursive: true)
            let testResult = source.find(elementsNamed: "test", recursive: true)
            let whateverResult = source.find(elementsNamed: "whatever", recursive: true)

            #expect(stringResult.isEmpty)
            #expect(cannotFind.isEmpty)
            #expect(testResult.count == 2)
            #expect(whateverResult.count == 1)
            #expect(testResult == [XWElement(name: "test", content: "value"), XWElement(name: "test")])
            #expect(whateverResult == [XWElement(name: "whatever")])
        }

        @Test
        func findingFirstObjectRecursive() {
            let string: XWElement.Content = [.string("some_string")]
            let source: XWElement.Content = [
                .element(XWElement(name: "test_something",
                                   elements: XWElement(name: "test",
                                                       attributes: ["is": "not"],
                                                       content: "value"))),
                .element(XWElement(name: "test_it")),
                .element(XWElement(name: "is", elements: [
                    XWElement(name: "add_that", elements: [
                        XWElement(name: "to_some", elements: [
                            XWElement(name: "deeper"),
                            XWElement(name: "levels", elements: [
                                XWElement(name: "deeper_and"),
                                XWElement(name: "whatever", content: "this is deep down"),
                            ]),
                        ]),
                        XWElement(name: "test"),
                        XWElement(name: "deeper again"),
                        XWElement(name: "whatever", content: "not so deep"),
                        XWElement(name: "deeper"),
                    ]),
                    XWElement(name: "deeper again"),
                    XWElement(name: "deeper"),
                ])),
                .element(XWElement(name: "here_is")),
                .element(XWElement(name: "test_something")),
            ]

            let stringResult = string.findFirst(elementNamed: .init("something"), recursive: true)
            let cannotFind = source.findFirst(elementNamed: "not_existent", recursive: true)
            let testResult = source.findFirst(elementNamed: "test", recursive: true)
            let whateverResult = source.findFirst(elementNamed: "whatever", recursive: true)

            #expect(stringResult == nil)
            #expect(cannotFind == nil)
            #expect(testResult != nil)
            #expect(whateverResult != nil)
            #expect(testResult?.content == ["value"])
            // Make sure we only recurse lazily. We don't want to go into the deepest abyss if we can stay in shallower waters.
            #expect(whateverResult?.content == ["not so deep"])
        }

        @Test
        func findingLastObjectRecursive() {
            let string: XWElement.Content = [.string("testStr")]
            let source: XWElement.Content = [
                .element(XWElement(name: "test_something",
                                   elements: XWElement(name: "test", content: "value"))),
                .element(XWElement(name: "test_it")),
                .element(XWElement(name: "is", elements: [
                    XWElement(name: "add", elements: [
                        XWElement(name: "some", elements: [
                            XWElement(name: "deeper", attributes: ["again": "here"]),
                            XWElement(name: "levels", elements: [
                                XWElement(name: "deeper"),
                                XWElement(name: "whatever", content: "deep down no one reaches"),
                            ]),
                        ]),
                        XWElement(name: "whatever", content: "not so deep"),
                        XWElement(name: "lost we are"),
                        XWElement(name: "deeper"),
                    ]),
                    XWElement(name: "deeper"),
                    XWElement(name: "help me"),
                ])),
                .element(XWElement(name: "here", elements: XWElement(name: "test"))),
                .element(XWElement(name: "test_something")),
            ]

            let stringResult = string.findLast(elementNamed: "something", recursive: true)
            let cannotFind = source.findLast(elementNamed: "not_existent", recursive: true)
            let testResult = source.findLast(elementNamed: "test", recursive: true)
            let whateverResult = source.findLast(elementNamed: "whatever", recursive: true)

            #expect(stringResult == nil)
            #expect(cannotFind == nil)
            #expect(testResult != nil)
            #expect(whateverResult != nil)
            #expect(testResult?.content.isEmpty == true)
            // Make sure we only recurse lazily. We don't want to go into the deepest abyss if we can stay in shallower waters.
            #expect(whateverResult?.content == ["not so deep"])
        }
    }
}

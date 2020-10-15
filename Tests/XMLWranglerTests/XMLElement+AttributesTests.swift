import XCTest
@testable import XMLWrangler

final class XMLElement_AttributesTests: XCTestCase {
    private typealias Attributes = XWElement.Attributes

    private enum RawRepAttrContent: String, XMLAttributeContentRepresentable {
        case test
    }

    private struct LossLessAttrContent: LosslessStringConvertible, ExpressibleByXMLAttributeContent {
        let description: String

        init?(_ description: String) {
            self.description = description
        }
    }

    private enum BothAttrContent: String, LosslessStringConvertible, XMLAttributeContentRepresentable {
        case test

        var description: String { rawValue }

        init?(_ description: String) {
            self.init(rawValue: description)
        }
    }

    func testXMLAttributeContentConvrtibleDefaultImplementation() {
        XCTAssertEqual(String("abc").xmlAttributeContent, .init("abc"))
        XCTAssertEqual(String(xmlAttributeContent: "abc"), "abc")
        XCTAssertEqual(RawRepAttrContent.test.xmlAttributeContent, .init(RawRepAttrContent.test.rawValue))
        XCTAssertEqual(RawRepAttrContent(xmlAttributeContent: "test"), .test)
        XCTAssertEqual(LossLessAttrContent(xmlAttributeContent: "testDesc")?.description, "testDesc")
        XCTAssertEqual(BothAttrContent(xmlAttributeContent: "test"), .test)
        XCTAssertEqual(BothAttrContent.test.xmlAttributeContent, .init(BothAttrContent.test.rawValue))
    }

    func testAttributesKey() {
        let key = Attributes.Key("testKey")
        XCTAssertEqual(key.rawValue, "testKey")
        XCTAssertEqual(key.description, key.rawValue)
        XCTAssertEqual(key.debugDescription, "\(Attributes.Key.self)(\(key.rawValue))")
        XCTAssertEqual("testKey", key)
    }

    func testAttributesContent() {
        let content = Attributes.Content("testValue")
        XCTAssertEqual(content.rawValue, "testValue")
        XCTAssertEqual(content.description, content.rawValue)
        XCTAssertEqual(content.debugDescription, "\(Attributes.Content.self)(\(content.rawValue))")
        XCTAssertEqual("testValue", content)
        XCTAssertEqual(content.xmlAttributeContent, content)
        XCTAssertEqual(.init(xmlAttributeContent: content), content)
    }

    func testAttributesInitialization() {
        XCTAssertTrue(Attributes().storage.isEmpty)
        XCTAssertGreaterThanOrEqual(Attributes(minimumCapacity: 5).storage.capacity, 5)
        XCTAssertEqual(Attributes(uniqueKeysWithContents: [("a", "b")]).storage, ["a": "b"])
        XCTAssertEqual(Attributes([("a", "b"), ("a", "c")], uniquingKeysWith: { $1 }).storage, ["a": "c"])
        XCTAssertEqual((["a": "b", "test": RawRepAttrContent.test] as Attributes).storage,
                       ["a": "b", "test": "test"])
    }

    func testAttributesSubscripts() {
        var attributes = Attributes()
        attributes["a"] = "b"
        XCTAssertEqual(attributes.storage, ["a": "b"])
        XCTAssertEqual(attributes["c", default: "x"], "x")
        attributes["e", default: "x"] = "f"
        XCTAssertEqual(attributes.storage["e"], "f")
    }

    func testAttributesFiltering() {
        let attributes: Attributes = ["a": "b", "c": "d", "e": "f"]
        XCTAssertEqual(attributes.filter { $0.key == "a" }.storage, ["a": "b"])
    }

    func testAttributesUpdateContent() {
        var attributes: Attributes = ["a": "b"]
        let beforeUpdate = attributes.updateContent("y", forKey: "a")
        let nonexisting = attributes.updateContent("d", forKey: "c")
        XCTAssertEqual(attributes.storage, ["a": "y", "c": "d"])
        XCTAssertEqual(beforeUpdate, "b")
        XCTAssertNil(nonexisting)
    }

    func testAttributeRemoveContent() {
        var attributes: Attributes = ["a": "b", "c": "d"]
        let removed = attributes.removeContent(forKey: "c")
        let nonexisting = attributes.removeContent(forKey: "x")
        XCTAssertEqual(attributes.storage, ["a": "b"])
        XCTAssertEqual(removed, "d")
        XCTAssertNil(nonexisting)
    }

    func testAttributeMerging() {
        var attrs1: Attributes = ["abc": "def"]
        let attrs2: Attributes = ["ghi": "jkl"]
        XCTAssertEqual(attrs1.merging([("mno", "pqr"), ("abc", "xyz")], uniquingKeysWith: { $1 }).storage,
                       ["abc": "xyz", "mno": "pqr"])
        XCTAssertEqual(attrs1.merging(attrs2, uniquingKeysWith: { $1 }).storage,
                       ["abc": "def", "ghi": "jkl"])
        attrs1.merge([("mno", "pqr"), ("abc", "xyz")], uniquingKeysWith: { $1 })
        XCTAssertEqual(attrs1.storage, ["abc": "xyz", "mno": "pqr"])
        attrs1.merge(attrs2, uniquingKeysWith: { $1 })
        XCTAssertEqual(attrs1.storage, ["abc": "xyz", "mno": "pqr", "ghi": "jkl"])
    }

    func testRemoveAll() {
        var attrs1: Attributes = ["ab": "cd"]
        var attrs2: Attributes = ["df": "gh"]
        attrs1.removeAll()
        attrs2.removeAll(keepingCapacity: true)
        XCTAssertTrue(attrs1.storage.isEmpty)
        XCTAssertEqual(attrs1.storage.capacity, 0)
        XCTAssertTrue(attrs2.storage.isEmpty)
        XCTAssertGreaterThanOrEqual(attrs2.storage.capacity, 1)
    }

    func testDescriptions() {
        let attrs: Attributes = ["ab": "df"]
        XCTAssertEqual(attrs.description, """
        \(Attributes.self) [1 key/content pair(s)] {
        \(attrs.storage.map { "    \($0.key): \($0.value)" }.joined(separator: "\n"))
        }
        """)
        XCTAssertEqual(attrs.debugDescription, """
        \(Attributes.self) [1 key/content pair(s)] {
        \(attrs.storage.map { "    \($0.key): \($0.value.debugDescription)" }.joined(separator: "\n"))
        }
        """)
    }

    func testKeysAccessor() {
        let attrs: Attributes = ["x": "y"]
        XCTAssertEqual(attrs.keys.count, 1)
        XCTAssertEqual(attrs.keys.first, "x")
    }

    func testContentsAccessor() {
        var attrs: Attributes = ["z": "h"]
        XCTAssertEqual(attrs.contents.count, 1)
        XCTAssertEqual(attrs.contents.first, "h")
        attrs.contents[attrs.contents.startIndex] = "y"
        XCTAssertEqual(attrs.storage, ["z": "y"])
    }

    func testDictionaryInitializer() {
        let attrs: Attributes = ["this": "test"]
        XCTAssertEqual(Dictionary(elementsOf: attrs), attrs.storage)
    }

    func testSequenceConformance() {
        let attrs: Attributes = ["seq": "test"]
        XCTAssertEqual(attrs.underestimatedCount, attrs.storage.underestimatedCount)
        var iterator = attrs.makeIterator()
        let first = iterator.next()
        XCTAssertNotNil(first)
        XCTAssertTrue(try XCTUnwrap(first) == ("seq", "test"))
        XCTAssertNil(iterator.next())
    }

    func testCollectionConformance() {
        let attrs: Attributes = ["coll": "conform"]
        XCTAssertEqual(attrs.isEmpty, attrs.storage.isEmpty)
        XCTAssertEqual(attrs.count, attrs.storage.count)
        XCTAssertEqual(attrs.startIndex.storageIndex, attrs.storage.startIndex)
        XCTAssertEqual(attrs.endIndex.storageIndex, attrs.storage.endIndex)
        XCTAssertEqual(attrs.index(after: attrs.startIndex).storageIndex,
                       attrs.storage.index(after: attrs.storage.startIndex))
        XCTAssertTrue(attrs[attrs.startIndex] == attrs.storage[attrs.storage.startIndex])
        XCTAssertTrue(attrs.startIndex < attrs.endIndex)
    }

    func testAttributeKeysDescriptions() {
        let attrKeys = Attributes(storage: ["a": "b", "c": "d"]).keys
        XCTAssertEqual(attrKeys.description, Array(attrKeys.storage).description)
        XCTAssertEqual(attrKeys.debugDescription, Array(attrKeys.storage).debugDescription)
    }

    func testAttributeKeysSequenceConformance() {
        let attrKeys = Attributes(storage: ["x": "y"]).keys
        var iterator = attrKeys.makeIterator()
        XCTAssertEqual(iterator.next(), "x")
        XCTAssertNil(iterator.next())
    }

    func testAttributeKeysCollectionConformance() {
        let attrKeys = Attributes(storage: ["h": "x"]).keys
        XCTAssertEqual(attrKeys.startIndex.storageIndex, attrKeys.storage.startIndex)
        XCTAssertEqual(attrKeys.endIndex.storageIndex, attrKeys.storage.endIndex)
        XCTAssertEqual(attrKeys[attrKeys.startIndex], attrKeys.storage[attrKeys.storage.startIndex])
        XCTAssertEqual(attrKeys.index(after: attrKeys.startIndex).storageIndex,
                       attrKeys.storage.index(after: attrKeys.storage.startIndex))
    }

    func testAttributeContentsDescriptions() {
        let attrContents = Attributes(storage: ["a": "b", "c": "d"]).contents
        XCTAssertEqual(attrContents.description, Array(attrContents.storage).description)
        XCTAssertEqual(attrContents.debugDescription, Array(attrContents.storage).debugDescription)
    }

    func testAttributeContentsSequenceConformance() {
        let attrContents = Attributes(storage: ["e": "g"]).contents
        var iterator = attrContents.makeIterator()
        XCTAssertEqual(iterator.next(), "g")
        XCTAssertNil(iterator.next())
    }

    func testAttributeContentsCollectionConformance() {
        let attrContents = Attributes(storage: ["s": "t"]).contents
        XCTAssertEqual(attrContents.startIndex.storageIndex, attrContents.storage.startIndex)
        XCTAssertEqual(attrContents.endIndex.storageIndex, attrContents.storage.endIndex)
        XCTAssertEqual(attrContents[attrContents.startIndex], attrContents.storage[attrContents.storage.startIndex])
        XCTAssertEqual(attrContents.index(after: attrContents.startIndex).storageIndex,
                       attrContents.storage.index(after: attrContents.storage.startIndex))
    }

    func testAttributeContentsMutableCollectionConformance() {
        var attrContents = Attributes(storage: ["s": "t"]).contents
        XCTAssertEqual(attrContents.storage.first, "t")
        attrContents[attrContents.startIndex] = "new"
        XCTAssertEqual(attrContents.storage.first, "new")
    }
}

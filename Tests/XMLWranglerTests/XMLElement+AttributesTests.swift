import Testing
@testable import XMLWrangler

extension XMLElementTests {
    @Suite
    struct AttributesTests {
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

        @Test
        func xmlAttributeContentConvertibleDefaultImplementation() {
            #expect(String("abc").xmlAttributeContent == .init("abc"))
            #expect(String(xmlAttributeContent: "abc") == "abc")
            #expect(RawRepAttrContent.test.xmlAttributeContent == .init(RawRepAttrContent.test.rawValue))
            #expect(RawRepAttrContent(xmlAttributeContent: "test") == .test)
            #expect(LossLessAttrContent(xmlAttributeContent: "testDesc")?.description == "testDesc")
            #expect(BothAttrContent(xmlAttributeContent: "test") == .test)
            #expect(BothAttrContent.test.xmlAttributeContent == .init(BothAttrContent.test.rawValue))
        }

        @Test
        func attributesKey() {
            let key = Attributes.Key("testKey")
            #expect(key.rawValue == "testKey")
            #expect(key.description == key.rawValue)
            #expect(key.debugDescription == "\(Attributes.Key.self)(\(key.rawValue))")
            #expect("testKey" == key)
        }

        @Test
        func attributesContent() {
            let content = Attributes.Content("testValue")
            #expect(content.rawValue == "testValue")
            #expect(content.description == content.rawValue)
            #expect(content.debugDescription == "\(Attributes.Content.self)(\(content.rawValue))")
            #expect("testValue" == content)
            #expect(content.xmlAttributeContent == content)
            #expect(.init(xmlAttributeContent: content) == content)
        }

        @Test
        func attributesInitialization() {
            #expect(Attributes().storage.isEmpty)
            #expect(Attributes(minimumCapacity: 5).storage.capacity >= 5)
            #expect(Attributes(uniqueKeysWithContents: [("a", "b")]).storage == ["a": "b"])
            #expect(Attributes([("a", "b"), ("a", "c")], uniquingKeysWith: { $1 }).storage == ["a": "c"])
            #expect((["a": "b", "test": RawRepAttrContent.test] as Attributes).storage == ["a": "b", "test": "test"])
        }

        @Test
        func attributesSubscripts() {
            var attributes = Attributes()
            attributes["a"] = "b"
            #expect(attributes.storage == ["a": "b"])
            #expect(attributes["c", default: "x"] == "x")
            attributes["e", default: "x"] = "f"
            #expect(attributes.storage["e"] == "f")
        }

        @Test
        func attributesFiltering() {
            let attributes: Attributes = ["a": "b", "c": "d", "e": "f"]
            #expect(attributes.filter { $0.key == "a" }.storage == ["a": "b"])
        }

        @Test
        func attributesUpdateContent() {
            var attributes: Attributes = ["a": "b"]
            let beforeUpdate = attributes.updateContent("y", forKey: "a")
            let nonexisting = attributes.updateContent("d", forKey: "c")
            #expect(attributes.storage == ["a": "y", "c": "d"])
            #expect(beforeUpdate == "b")
            #expect(nonexisting == nil)
        }

        @Test
        func attributeRemoveContent() {
            var attributes: Attributes = ["a": "b", "c": "d"]
            let removed = attributes.removeContent(forKey: "c")
            let nonexisting = attributes.removeContent(forKey: "x")
            #expect(attributes.storage == ["a": "b"])
            #expect(removed == "d")
            #expect(nonexisting == nil)
        }

        @Test
        func attributeMerging() {
            var attrs1: Attributes = ["abc": "def"]
            let attrs2: Attributes = ["ghi": "jkl"]
            #expect(attrs1.merging([("mno", "pqr"), ("abc", "xyz")], uniquingKeysWith: { $1 }).storage == ["abc": "xyz", "mno": "pqr"])
            #expect(attrs1.merging(attrs2, uniquingKeysWith: { $1 }).storage == ["abc": "def", "ghi": "jkl"])
            attrs1.merge([("mno", "pqr"), ("abc", "xyz")], uniquingKeysWith: { $1 })
            #expect(attrs1.storage == ["abc": "xyz", "mno": "pqr"])
            attrs1.merge(attrs2, uniquingKeysWith: { $1 })
            #expect(attrs1.storage == ["abc": "xyz", "mno": "pqr", "ghi": "jkl"])
        }

        @Test
        func removeAll() {
            var attrs1: Attributes = ["ab": "cd"]
            var attrs2: Attributes = ["df": "gh"]
            attrs1.removeAll() // keepingCapacity: false
            attrs2.removeAll(keepingCapacity: true)
            #expect(attrs1.storage.isEmpty)
            #expect(attrs1.storage.capacity == 0)
            #expect(attrs2.storage.isEmpty)
            #expect(attrs2.storage.capacity >= 1)
        }

        @Test
        func descriptions() {
            let attrs: Attributes = ["ab": "df"]
            #expect(attrs.description == """
            \(Attributes.self) [1 key/content pair(s)] {
            \(attrs.storage.map { "    \($0.key): \($0.value)" }.joined(separator: "\n"))
            }
            """)
            #expect(attrs.debugDescription == """
            \(Attributes.self) [1 key/content pair(s)] {
            \(attrs.storage.map { "    \($0.key): \($0.value.debugDescription)" }.joined(separator: "\n"))
            }
            """)
        }

        @Test
        func keysAccessor() {
            let attrs: Attributes = ["x": "y"]
            #expect(attrs.keys.count == 1)
            #expect(attrs.keys.first == "x")
        }

        @Test
        func contentsAccessor() {
            var attrs: Attributes = ["z": "h"]
            #expect(attrs.contents.count == 1)
            #expect(attrs.contents.first == "h")
            attrs.contents[attrs.contents.startIndex] = "y"
            #expect(attrs.storage == ["z": "y"])
        }

        @Test
        func dictionaryInitializer() {
            let attrs: Attributes = ["this": "test"]
            #expect(Dictionary(elementsOf: attrs) == attrs.storage)
        }

        @Test
        func sequenceConformance() throws {
            let attrs: Attributes = ["seq": "test"]
            #expect(attrs.underestimatedCount == attrs.storage.underestimatedCount)
            var iterator = attrs.makeIterator()
            let first = try #require({ iterator.next() }())
            #expect(first == ("seq", "test"))
            #expect(iterator.next() == nil)
        }

        @Test
        func collectionConformance() {
            let attrs: Attributes = ["coll": "conform"]
            #expect(attrs.isEmpty == attrs.storage.isEmpty)
            #expect(attrs.count == attrs.storage.count)
            #expect(attrs.startIndex.storageIndex == attrs.storage.startIndex)
            #expect(attrs.endIndex.storageIndex == attrs.storage.endIndex)
            #expect(attrs.index(after: attrs.startIndex).storageIndex == attrs.storage.index(after: attrs.storage.startIndex))
            #expect(attrs[attrs.startIndex] == attrs.storage[attrs.storage.startIndex])
            #expect(attrs.startIndex < attrs.endIndex)
        }

        @Test
        func attributeKeysDescriptions() {
            let attrKeys = Attributes(storage: ["a": "b", "c": "d"]).keys
            #expect(attrKeys.description == Array(attrKeys.storage).description)
            #expect(attrKeys.debugDescription == Array(attrKeys.storage).debugDescription)
        }

        @Test
        func attributeKeysSequenceConformance() {
            let attrKeys = Attributes(storage: ["x": "y"]).keys
            var iterator = attrKeys.makeIterator()
            #expect(iterator.next() == "x")
            #expect(iterator.next() == nil)
        }

        @Test
        func attributeKeysCollectionConformance() {
            let attrKeys = Attributes(storage: ["h": "x"]).keys
            #expect(attrKeys.startIndex.storageIndex == attrKeys.storage.startIndex)
            #expect(attrKeys.endIndex.storageIndex == attrKeys.storage.endIndex)
            #expect(attrKeys[attrKeys.startIndex] == attrKeys.storage[attrKeys.storage.startIndex])
            #expect(attrKeys.index(after: attrKeys.startIndex).storageIndex
                    ==
                    attrKeys.storage.index(after: attrKeys.storage.startIndex))
        }

        @Test
        func attributeContentsDescriptions() {
            let attrContents = Attributes(storage: ["a": "b", "c": "d"]).contents
            #expect(attrContents.description == Array(attrContents.storage).description)
            #expect(attrContents.debugDescription == Array(attrContents.storage).debugDescription)
        }

        @Test
        func attributeContentsSequenceConformance() {
            let attrContents = Attributes(storage: ["e": "g"]).contents
            var iterator = attrContents.makeIterator()
            #expect(iterator.next() == "g")
            #expect(iterator.next() == nil)
        }

        @Test
        func attributeContentsCollectionConformance() {
            let attrContents = Attributes(storage: ["s": "t"]).contents
            #expect(attrContents.startIndex.storageIndex == attrContents.storage.startIndex)
            #expect(attrContents.endIndex.storageIndex == attrContents.storage.endIndex)
            #expect(attrContents[attrContents.startIndex] == attrContents.storage[attrContents.storage.startIndex])
            #expect(attrContents.index(after: attrContents.startIndex).storageIndex
                    ==
                    attrContents.storage.index(after: attrContents.storage.startIndex))
        }

        @Test
        func attributeContentsMutableCollectionConformance() {
            var attrContents = Attributes(storage: ["s": "t"]).contents
            #expect(attrContents.storage.first == "t")
            attrContents[attrContents.startIndex] = "new"
            #expect(attrContents.storage.first == "new")
        }
    }
}

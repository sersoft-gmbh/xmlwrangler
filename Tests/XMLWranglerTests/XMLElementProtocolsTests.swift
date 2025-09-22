import Testing
import XMLWrangler

@Suite
struct XMLElementProtocolsTests {
    private enum RepresentableEnum: String, RawRepresentable, ExpressibleByXMLElement {
        case a
    }

    private struct ConvertibleStruct: LosslessStringConvertible, ExpressibleByXMLElement {
        let description: String

        init?(_ description: String) {
            self.description = description
        }
    }

    private enum Both: String, RawRepresentable, LosslessStringConvertible, ExpressibleByXMLElement {
        case a

        var description: String { rawValue }

        init?(_ description: String) {
            self.init(rawValue: description)
        }
    }

    private let testRoot = XWElement(name: "irrelevant", content: "a")

    @Test
    func convenienceImplementations() throws {
        #expect(try testRoot.converted(to: RepresentableEnum.self) == .a)
        #expect(try testRoot.converted(to: ConvertibleStruct.self).description == "a")
        #expect(try testRoot.converted(to: Both.self) == .a)
    }
}

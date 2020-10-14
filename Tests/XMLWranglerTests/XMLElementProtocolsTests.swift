import XCTest
import XMLWrangler

final class XMLElementProtocolsTests: XCTestCase {
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

    func testConvenienceImplementations() {
        XCTAssertEqual(try testRoot.converted(to: RepresentableEnum.self), .a)
        XCTAssertEqual(try testRoot.converted(to: ConvertibleStruct.self).description, "a")
        XCTAssertEqual(try testRoot.converted(to: Both.self), .a)
    }
}

import XCTest
import XMLWrangler

final class GitHubIssueTests: XCTestCase {
    // https://github.com/sersoft-gmbh/xmlwrangler/issues/11
    func testIssue11() throws {
        let str = """
        <text>Ich bin zerknirscht und verzweifelt
        über meine schwere Schuld.
        Solch ein Opfer gefällt dir, o Gott,
        du wirst es nicht ablehnen.</text>
        """
        XCTAssertEqual(try XWElement.parse(str).stringContent(),
                       "Ich bin zerknirscht und verzweifelt\nüber meine schwere Schuld.\nSolch ein Opfer gefällt dir, o Gott,\ndu wirst es nicht ablehnen.")
    }
}

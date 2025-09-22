import Testing
import XMLWrangler

@Suite
struct GitHubIssueTests {
    @Test(.bug("https://github.com/sersoft-gmbh/xmlwrangler/issues/11", id: 11))
    func issue11() throws {
        let str = """
        <text>Ich bin zerknirscht und verzweifelt
        über meine schwere Schuld.
        Solch ein Opfer gefällt dir, o Gott,
        du wirst es nicht ablehnen.</text>
        """
        #expect(try XWElement.parse(str).stringContent()
                ==
                "Ich bin zerknirscht und verzweifelt\nüber meine schwere Schuld.\nSolch ein Opfer gefällt dir, o Gott,\ndu wirst es nicht ablehnen.")
    }

    @Test(.bug("https://github.com/sersoft-gmbh/xmlwrangler/issues/120", id: 120))
    func issue120() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <root myattr="myvalue">
            <child1>One &amp; two</child1>
        </root>
        """
        let content = try XMLElement.parse(xml)
            .element(at: "child1")
            .stringContent()
        #expect("One & two" == content)
    }
}

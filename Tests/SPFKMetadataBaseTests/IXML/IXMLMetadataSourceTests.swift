// Copyright Ryan Francesconi. All Rights Reserved.

import AEXML
import Foundation
import Testing

@testable import SPFKMetadataBase

/// An iXML document nothing modeled changed in is handed back as it was read.
struct IXMLMetadataSourceTests {
    /// A comment, a CDATA section and a trailing line break: what a parse and re-serialization lose.
    private let chunk = """
    <?xml version="1.0" encoding="UTF-8"?>
    <BWFXML>
    <!-- Written by another recorder -->
    <PROJECT>Before</PROJECT>
    <USER><![CDATA[Scene 12 <take 3>]]></USER>
    </BWFXML>\r\n
    """

    private var normalized: String {
        get throws { try IXMLMetadata.document(xml: chunk).xml }
    }

    @Test func uneditedDocumentIsReturnedAsRead() throws {
        #expect(try IXMLMetadata(xml: chunk).xml == chunk)
    }

    @Test func fieldSetToItsOwnValueIsReturnedAsRead() throws {
        var ixml = try IXMLMetadata(xml: chunk)
        ixml.project = "Before"
        #expect(ixml.xml == chunk)
    }

    @Test func editedDocumentIsRendered() throws {
        var ixml = try IXMLMetadata(xml: chunk)
        ixml.project = "After"

        let edited = ixml.xml
        #expect(edited != chunk)
        #expect(try IXMLMetadata(xml: edited).project == "After")
        #expect(try IXMLMetadata(xml: edited).userContent == IXMLMetadata(xml: chunk).userContent)
    }

    @Test func documentsDifferingOnlyInSerializationAreEqual() throws {
        #expect(try IXMLMetadata(xml: chunk) == IXMLMetadata(xml: normalized))
    }

    @Test func uneditedTextMatchesExactly() {
        #expect(IXMLMetadata.isUnedited(chunk, stored: chunk))
        #expect(IXMLMetadata.isUnedited(nil, stored: nil))
        #expect(IXMLMetadata.isUnedited("", stored: nil))
        #expect(!IXMLMetadata.isUnedited(nil, stored: chunk))
        #expect(!IXMLMetadata.isUnedited(chunk.replacingOccurrences(of: "Before", with: "After"), stored: chunk))
    }

    @Test func commentOrWhitespaceEditIsAnEdit() {
        #expect(!IXMLMetadata.isUnedited(chunk.replacingOccurrences(of: "<!-- Written by another recorder -->\n", with: ""), stored: chunk))
        #expect(!IXMLMetadata.isUnedited(chunk.replacingOccurrences(of: "\r\n", with: ""), stored: chunk))
    }

    @Test func reserializedFormOfTheStoredTextIsUnedited() throws {
        #expect(try IXMLMetadata.isUnedited(normalized, stored: chunk))
    }

    @Test func unparseableStoredTextMatchesOnlyExactly() {
        let malformed = "<BWFXML><PROJECT>Before</PROJECT>"
        #expect(IXMLMetadata.isUnedited(malformed, stored: malformed))
        #expect(!IXMLMetadata.isUnedited(malformed + " ", stored: malformed))
    }
}

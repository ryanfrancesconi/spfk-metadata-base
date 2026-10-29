// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import Testing

@testable import SPFKMetadataBase

/// iXML with an unescaped `&` in a value, as some catalogers write it.
@Suite
final class IXMLMetadataBareAmpersandTests {
    private let xml = "<BWFXML><NOTE>Arcs & Zaps</NOTE><SCENE>Fish &amp; Chips &#38; Peas</SCENE></BWFXML>"

    @Test func aBareAmpersandIsReadAsText() throws {
        let ixml = try IXMLMetadata(xml: xml)

        #expect(ixml.note == "Arcs & Zaps")
        #expect(ixml.scene == "Fish & Chips & Peas")
    }

    @Test func anUneditedDocumentWritesBackTheTextAsRead() throws {
        #expect(try IXMLMetadata(xml: xml).xml == xml)
    }

    @Test func anEditedDocumentIsWellFormed() throws {
        var ixml = try IXMLMetadata(xml: xml)
        ixml.project = "Odyssey"

        let written = ixml.xml
        #expect(written.contains("Arcs &amp; Zaps"))
        #expect(try IXMLMetadata(xml: written).note == "Arcs & Zaps")
    }

    @Test func otherMalformedXMLStillThrows() {
        #expect(throws: (any Error).self) {
            try IXMLMetadata(xml: "<BWFXML><NOTE>Arcs & Zaps</BWFXML>")
        }
    }
}

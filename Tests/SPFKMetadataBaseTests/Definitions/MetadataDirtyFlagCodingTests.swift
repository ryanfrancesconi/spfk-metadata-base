// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKMetadataBase
import Testing

@Suite("Metadata dirty flag coding")
struct MetadataDirtyFlagCodingTests {
    /// Libraries store the raw values, so a renamed case still reads and writes its stored spelling.
    @Test func renamedCasesKeepTheirStoredSpellings() throws {
        let stored = Data(#"["metadata","image"]"#.utf8)
        #expect(try JSONDecoder().decode(Set<MetadataDirtyFlag>.self, from: stored) == [.tags, .artwork])

        let encoded = try JSONEncoder().encode([MetadataDirtyFlag.tags, .artwork])
        #expect(String(decoding: encoded, as: UTF8.self) == #"["metadata","image"]"#)
    }
}

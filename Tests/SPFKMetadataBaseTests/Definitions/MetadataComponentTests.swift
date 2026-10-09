// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKMetadataBase
import Testing

@Suite("Metadata component")
struct MetadataComponentTests {
    /// A save clears the flags it wrote and keeps the rest, so every component must belong to exactly
    /// the flag whose save writes it.
    @Test func eachComponentBelongsToTheFlagThatWritesIt() {
        for component in MetadataComponent.allCases {
            let owners = MetadataDirtyFlag.allCases.filter { $0.components.contains(component) }
            #expect(owners == [component.dirtyFlag])
        }

        #expect(MetadataDirtyFlag.metadata.components == [.tags, .rating, .bext, .ixml])
        #expect(MetadataDirtyFlag.finderTags.components.isEmpty)
    }
}

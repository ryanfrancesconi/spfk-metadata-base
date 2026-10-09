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

        #expect(MetadataDirtyFlag.tags.components == [.tags, .rating, .bext, .ixml])
        #expect(MetadataDirtyFlag.finderTags.components == [.finderTags])
    }

    /// Every flag has a component, so a save's `written` can always say whether to clear it.
    @Test func everyFlagIsWrittenByAComponent() {
        for flag in MetadataDirtyFlag.allCases {
            #expect(!flag.components.isEmpty, "\(flag)")
        }
    }

    /// A flag is cleared only once every part of it was written: a failed rating keeps the tags flag.
    @Test func aFlagIsFullyWrittenOnlyByAllItsComponents() {
        #expect(MetadataDirtyFlag.tags.isFullyWritten(by: [.tags, .rating, .bext, .ixml, .markers]))
        #expect(!MetadataDirtyFlag.tags.isFullyWritten(by: [.tags, .bext, .ixml]))
        #expect(MetadataDirtyFlag.markers.isFullyWritten(by: [.markers]))
        #expect(!MetadataDirtyFlag.image.isFullyWritten(by: []))
    }
}

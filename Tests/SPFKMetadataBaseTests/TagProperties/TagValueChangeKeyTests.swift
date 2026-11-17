// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import SPFKTesting
import Testing

@testable import SPFKMetadataBase

@Suite(.tags(.unsavedEdits))
final class TagValueChangeKeyTests {
    /// A custom tag spelled like a standard key's raw value must not share its key, or restoring
    /// one would restore the other.
    @Test func standardAndCustomTagsWithTheSameSpellingGetDistinctKeys() throws {
        let disk = TagData(tags: [.album: "Old"], customTags: [TagKey.album.rawValue: "custom old"])
        let edited = TagData(tags: [.album: "New"], customTags: [TagKey.album.rawValue: "custom new"])

        let changes = edited.difference(from: disk)

        #expect(Set(changes.map(\.key)).count == 2)

        let standard = try #require(changes.first { $0.tagKey != nil })
        #expect(standard.tagKey == .album)
        #expect(standard.customTagKey == nil)
        #expect(standard.after == "New")

        let custom = try #require(changes.first { $0.customTagKey != nil })
        #expect(custom.customTagKey == TagKey.album.rawValue)
        #expect(custom.tagKey == nil)
        #expect(custom.after == "custom new")
    }

    @Test func anInfoChangeIsKeyedByItsFourCharacterID() {
        let disk = RIFFInfoFields(fields: ["ISRF": "Tape"])
        let edited = RIFFInfoFields(fields: ["ISRF": "DAT"])

        let changes = edited.difference(from: disk)

        #expect(changes.map(\.key) == ["ISRF"])
        #expect(changes.map(\.name) == ["INFO: Source Form"])
    }
}

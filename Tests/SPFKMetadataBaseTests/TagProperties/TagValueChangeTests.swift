// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import Testing

@testable import SPFKMetadataBase

@Suite
final class TagValueChangeTests {
    @Test func aChangedValueReportsBothSides() {
        let disk = TagData(tags: [.keywords: "aircraft, traffic_noise"])
        let edited = TagData(tags: [.keywords: "Aircraft, Airplane"])

        let changes = edited.difference(from: disk)

        #expect(changes.count == 1)
        #expect(changes.first?.name == TagKey.keywords.displayName)
        #expect(changes.first?.before == "aircraft, traffic_noise")
        #expect(changes.first?.after == "Aircraft, Airplane")
    }

    /// The case the register of empty frames produces: a file carrying `TALB` with nothing in it
    /// reads back as `""`, and an element that never touched the field holds the same. Reporting
    /// that as a change would bury the one field that moved.
    @Test func matchingValuesAreNotChanges() {
        let disk = TagData(tags: [.album: "", .artist: "", .keywords: "same"])
        let edited = TagData(tags: [.album: "", .artist: "", .keywords: "same"])

        #expect(edited.difference(from: disk).isEmpty)
    }

    @Test func anAbsentKeyOnEitherSideCountsAsEmpty() {
        let disk = TagData(tags: [.artist: "Someone"])
        let edited = TagData(tags: [.title: "Added"])

        let changes = edited.difference(from: disk)

        #expect(changes.count == 2)

        let cleared = changes.first { $0.name == TagKey.artist.displayName }
        #expect(cleared?.before == "Someone")
        #expect(cleared?.after == "")

        let added = changes.first { $0.name == TagKey.title.displayName }
        #expect(added?.before == "")
        #expect(added?.after == "Added")
    }

    @Test func customTagsAreComparedByRawKey() {
        let disk = TagData(customTags: ["UCS_EXTRA": "one", "UNTOUCHED": "same"])
        let edited = TagData(customTags: ["UCS_EXTRA": "two", "UNTOUCHED": "same"])

        let changes = edited.difference(from: disk)

        #expect(changes.map(\.name) == ["UCS_EXTRA"])
        #expect(changes.first?.after == "two")
    }

    /// Standard and custom keys share one sorted list, so a dialog listing them cannot show two
    /// unrelated orderings.
    @Test func changesAreSortedByFieldName() {
        let disk = TagData()
        let edited = TagData(
            tags: [.album: "b", .artist: "a"],
            customTags: ["ZZZ": "z", "AAA": "a"]
        )

        let names = edited.difference(from: disk).map(\.name)

        #expect(names == names.sorted())
        #expect(names.count == 4)
    }

    @Test func aDifferenceAgainstItselfIsEmpty() {
        let data = TagData(tags: [.title: "x"], customTags: ["Y": "z"])

        #expect(data.difference(from: data).isEmpty)
    }

    @Test func tagPropertiesComparesTagsAndIgnoresAudioProperties() {
        var disk = TagProperties()
        disk.tags[.title] = "same"
        disk.audioProperties = AudioFormatProperties(channelCount: 2, sampleRate: 44100, duration: 10)

        var edited = TagProperties()
        edited.tags[.title] = "same"

        #expect(edited.difference(from: disk).isEmpty)
    }
}

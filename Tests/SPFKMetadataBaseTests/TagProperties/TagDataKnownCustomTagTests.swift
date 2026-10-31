// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import Testing

@testable import SPFKMetadataBase

/// A custom tag stored under a ``TagKey``'s TagLib key, from before that key existed.
struct TagDataKnownCustomTagTests {
    @Test func aCustomTagWithAKeyBecomesThatKey() {
        var data = TagData(customTags: ["ARCHIVALLOCATION": "BOOM Library", "SOURCEFORM": "1100"])
        data.promoteKnownCustomTags()

        #expect(data.tags == [.archivalLocation: "BOOM Library"])
        #expect(data.customTags == ["SOURCEFORM": "1100"])
    }

    @Test func aKnownValueWinsOverTheCustomOne() {
        var data = TagData(tags: [.subject: "The SFX Kit"], customTags: ["SUBJECT": "stale"])
        data.promoteKnownCustomTags()

        #expect(data.tags == [.subject: "The SFX Kit"])
        #expect(data.customTags.isEmpty)
    }

    /// TagLib keys are uppercase, so a custom tag spelled otherwise is a different tag.
    @Test func onlyTheExactTagLibKeyIsPromoted() {
        var data = TagData(customTags: ["Title": "not the title tag"])
        data.promoteKnownCustomTags()

        #expect(data.tags.isEmpty)
        #expect(data.customTags == ["Title": "not the title tag"])
    }

    @Test func decodingPromotes() throws {
        let stored = try JSONEncoder().encode(TagData(customTags: ["COMMISSIONED": "Articulated Sounds"]))
        let data = try JSONDecoder().decode(TagData.self, from: stored)

        #expect(data.tags == [.commissioned: "Articulated Sounds"])
        #expect(data.customTags.isEmpty)
    }
}

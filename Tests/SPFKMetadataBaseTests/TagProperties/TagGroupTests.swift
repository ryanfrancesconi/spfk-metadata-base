import Foundation
import Testing

@testable import SPFKMetadataBase

struct TagGroupTests {
    @Test func initFromTitle() {
        for set in TagGroup.allCases {
            let recovered = TagGroup(title: set.title)
            #expect(recovered == set, "Failed round-trip for \(set)")
        }
    }

    @Test func initFromTitleNil() {
        #expect(TagGroup(title: "Invalid") == nil)
    }

    @Test func commonTagsContents() {
        let keys = TagGroup.common.keys
        #expect(keys.contains(.title))
        #expect(keys.contains(.album))
        #expect(keys.contains(.artist))
        #expect(keys.contains(.genre))
        #expect(keys.contains(.date))
        #expect(keys.contains(.comment))
        #expect(keys.contains(.trackNumber))
    }

    @Test func musicTagsContents() {
        let keys = TagGroup.music.keys
        #expect(keys.contains(.bpm))
        #expect(keys.contains(.composer))
        #expect(keys.contains(.conductor))
        #expect(keys.contains(.initialKey))
        #expect(keys.contains(.lyrics))
    }

    @Test func loudnessTagsContents() {
        let keys = TagGroup.loudness.keys
        #expect(keys.contains(.loudnessIntegrated))
        #expect(keys.contains(.loudnessRange))
        #expect(keys.contains(.loudnessTruePeak))
        #expect(keys.contains(.loudnessMaxMomentary))
        #expect(keys.contains(.loudnessMaxShortTerm))
        #expect(keys.count == 5)
    }

    @Test func replayGainTagsContents() {
        let keys = TagGroup.replayGain.keys
        #expect(keys.contains(.replayGainTrackGain))
        #expect(keys.contains(.replayGainAlbumGain))
        #expect(keys.count == 7)
    }

    @Test func utilityTagsContents() {
        let keys = TagGroup.utility.keys
        #expect(keys.contains(.isrc))
        #expect(keys.contains(.releaseDate))
        #expect(keys.contains(.artistWebpage))
    }

    @Test func allTagKeysAccountedFor() {
        // every TagKey should appear in exactly one TagGroup
        var allKeysInSets: [TagKey] = []
        for set in TagGroup.allCases {
            allKeysInSets.append(contentsOf: set.keys)
        }

        for key in TagKey.allCases {
            let count = allKeysInSets.count(where: { $0 == key })
            #expect(count == 1, "\(key) appears \(count) times across TagGroups (expected 1)")
        }
    }

    @Test func noOverlapBetweenSets() {
        let sets = TagGroup.allCases
        for i in 0 ..< sets.count {
            for j in (i + 1) ..< sets.count {
                let overlap = Set(sets[i].keys).intersection(Set(sets[j].keys))
                #expect(overlap.isEmpty, "\(sets[i]) and \(sets[j]) share keys: \(overlap)")
            }
        }
    }
}

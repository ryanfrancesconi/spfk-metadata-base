import Foundation
import SPFKBase
import Testing

@testable import SPFKMetadataBase

struct TagDataDivergenceTests {
    // MARK: - Guard conditions

    @Test func emptyArrayReturnsEmpty() {
        #expect([TagData]().divergentTagKeyDisplayNames().isEmpty)
    }

    @Test func singleElementReturnsEmpty() {
        let data = TagData(tags: [.title: "Song A"])
        #expect([data].divergentTagKeyDisplayNames().isEmpty)
    }

    // MARK: - Standard tag keys (two elements)

    @Test func twoIdenticalStandardTagsNotDivergent() {
        let data1 = TagData(tags: [.title: "Same Title"])
        let data2 = TagData(tags: [.title: "Same Title"])
        #expect([data1, data2].divergentTagKeyDisplayNames().isEmpty)
    }

    @Test func twoDifferentStandardTagsAreDivergent() {
        let data1 = TagData(tags: [.title: "Song A"])
        let data2 = TagData(tags: [.title: "Song B"])
        let result = [data1, data2].divergentTagKeyDisplayNames()
        #expect(result.contains(TagKey.title.displayName))
        #expect(result.count == 1)
    }

    @Test func oneFilledOneEmptyValueAreDivergent() {
        let data1 = TagData(tags: [.title: "Song A"])
        let data2 = TagData(tags: [.title: ""])
        let result = [data1, data2].divergentTagKeyDisplayNames()
        #expect(result.contains(TagKey.title.displayName))
    }

    @Test func standardKeyAbsentFromOneElementIsDivergent() {
        // A key present in some elements but absent from others is divergent —
        // absent is treated as "" which differs from a real value.
        let data1 = TagData(tags: [.title: "Song A"])
        let data2 = TagData(tags: [:])
        let result = [data1, data2].divergentTagKeyDisplayNames()
        #expect(result.contains(TagKey.title.displayName))
    }

    @Test func standardKeyAbsentFromAllElementsNotDivergent() {
        // A key absent from every element is not divergent — all "values" are the same (absent).
        let data1 = TagData(tags: [:])
        let data2 = TagData(tags: [:])
        #expect([data1, data2].divergentTagKeyDisplayNames().isEmpty)
    }

    // MARK: - Standard tag keys (three elements)

    @Test func threeElementsAllDifferentAreDivergent() {
        let data1 = TagData(tags: [.title: "Song A"])
        let data2 = TagData(tags: [.title: "Song B"])
        let data3 = TagData(tags: [.title: "Song C"])
        let result = [data1, data2, data3].divergentTagKeyDisplayNames()
        #expect(result.contains(TagKey.title.displayName))
    }

    @Test func threeElementsAllSameNotDivergent() {
        let data1 = TagData(tags: [.title: "Same"])
        let data2 = TagData(tags: [.title: "Same"])
        let data3 = TagData(tags: [.title: "Same"])
        #expect([data1, data2, data3].divergentTagKeyDisplayNames().isEmpty)
    }

    @Test func threeElementsKeyMissingFromOneIsDivergent() {
        // Key in first and second but absent from third — divergent.
        let data1 = TagData(tags: [.title: "Song A"])
        let data2 = TagData(tags: [.title: "Song B"])
        let data3 = TagData(tags: [:])
        let result = [data1, data2, data3].divergentTagKeyDisplayNames()
        #expect(result.contains(TagKey.title.displayName))
    }

    @Test func threeElementsKeyMissingFromMiddleIsDivergent() {
        // Key in first and third but absent from second — divergent.
        let data1 = TagData(tags: [.title: "Song A"])
        let data2 = TagData(tags: [:])
        let data3 = TagData(tags: [.title: "Song B"])
        let result = [data1, data2, data3].divergentTagKeyDisplayNames()
        #expect(result.contains(TagKey.title.displayName))
    }

    @Test func threeElementsOneValueDiffersIsDivergent() {
        // Only one of three values differs — still divergent.
        let data1 = TagData(tags: [.title: "Song A"])
        let data2 = TagData(tags: [.title: "Song A"])
        let data3 = TagData(tags: [.title: "Song B"])
        let result = [data1, data2, data3].divergentTagKeyDisplayNames()
        #expect(result.contains(TagKey.title.displayName))
    }

    // MARK: - Mixed divergent and identical keys

    @Test func divergentAndIdenticalKeysMixed() {
        let data1 = TagData(tags: [.title: "Song A", .album: "Same Album"])
        let data2 = TagData(tags: [.title: "Song B", .album: "Same Album"])
        let result = [data1, data2].divergentTagKeyDisplayNames()
        #expect(result.contains(TagKey.title.displayName))
        #expect(!result.contains(TagKey.album.displayName))
    }

    @Test func multipleDivergentKeys() {
        let data1 = TagData(tags: [.title: "A", .album: "X", .artist: "Same"])
        let data2 = TagData(tags: [.title: "B", .album: "Y", .artist: "Same"])
        let result = [data1, data2].divergentTagKeyDisplayNames()
        #expect(result.contains(TagKey.title.displayName))
        #expect(result.contains(TagKey.album.displayName))
        #expect(!result.contains(TagKey.artist.displayName))
        #expect(result.count == 2)
    }

    @Test func resultContainsDisplayNameForStandardKey() {
        // Verifies the returned string is the display name, not the raw TagKey name.
        let data1 = TagData(tags: [.title: "A"])
        let data2 = TagData(tags: [.title: "B"])
        let result = [data1, data2].divergentTagKeyDisplayNames()
        #expect(result == Set([TagKey.title.displayName]))
    }

    // MARK: - Custom tags (two elements)

    @Test func twoIdenticalCustomTagsNotDivergent() {
        let data1 = TagData(customTags: ["CUSTOM_KEY": "Same"])
        let data2 = TagData(customTags: ["CUSTOM_KEY": "Same"])
        #expect([data1, data2].divergentTagKeyDisplayNames().isEmpty)
    }

    @Test func twoDifferentCustomTagsAreDivergent() {
        let data1 = TagData(customTags: ["CUSTOM_KEY": "Value A"])
        let data2 = TagData(customTags: ["CUSTOM_KEY": "Value B"])
        let result = [data1, data2].divergentTagKeyDisplayNames()
        #expect(result.contains("CUSTOM_KEY"))
        #expect(result.count == 1)
    }

    @Test func customKeyAbsentFromOneElementIsDivergent() {
        let data1 = TagData(customTags: ["CUSTOM_KEY": "Value"])
        let data2 = TagData(customTags: [:])
        let result = [data1, data2].divergentTagKeyDisplayNames()
        #expect(result.contains("CUSTOM_KEY"))
    }

    @Test func customKeyAbsentFromAllElementsNotDivergent() {
        let data1 = TagData(customTags: [:])
        let data2 = TagData(customTags: [:])
        #expect([data1, data2].divergentTagKeyDisplayNames().isEmpty)
    }

    // MARK: - Custom tags (three elements)

    @Test func threeElementsCustomKeyMissingFromOneIsDivergent() {
        let data1 = TagData(customTags: ["CUSTOM_KEY": "A"])
        let data2 = TagData(customTags: ["CUSTOM_KEY": "B"])
        let data3 = TagData(customTags: [:])
        let result = [data1, data2, data3].divergentTagKeyDisplayNames()
        #expect(result.contains("CUSTOM_KEY"))
    }

    @Test func threeElementsDifferentCustomTagsAreDivergent() {
        let data1 = TagData(customTags: ["CUSTOM_KEY": "A"])
        let data2 = TagData(customTags: ["CUSTOM_KEY": "B"])
        let data3 = TagData(customTags: ["CUSTOM_KEY": "C"])
        let result = [data1, data2, data3].divergentTagKeyDisplayNames()
        #expect(result.contains("CUSTOM_KEY"))
    }

    // MARK: - Mixed standard and custom

    @Test func bothStandardAndCustomDivergent() {
        let data1 = TagData(tags: [.title: "A"], customTags: ["CUSTOM_KEY": "X"])
        let data2 = TagData(tags: [.title: "B"], customTags: ["CUSTOM_KEY": "Y"])
        let result = [data1, data2].divergentTagKeyDisplayNames()
        #expect(result.contains(TagKey.title.displayName))
        #expect(result.contains("CUSTOM_KEY"))
        #expect(result.count == 2)
    }

    @Test func standardDivergentCustomIdentical() {
        let data1 = TagData(tags: [.title: "A"], customTags: ["CUSTOM_KEY": "Same"])
        let data2 = TagData(tags: [.title: "B"], customTags: ["CUSTOM_KEY": "Same"])
        let result = [data1, data2].divergentTagKeyDisplayNames()
        #expect(result.contains(TagKey.title.displayName))
        #expect(!result.contains("CUSTOM_KEY"))
    }

    @Test func standardIdenticalCustomDivergent() {
        let data1 = TagData(tags: [.title: "Same"], customTags: ["CUSTOM_KEY": "X"])
        let data2 = TagData(tags: [.title: "Same"], customTags: ["CUSTOM_KEY": "Y"])
        let result = [data1, data2].divergentTagKeyDisplayNames()
        #expect(!result.contains(TagKey.title.displayName))
        #expect(result.contains("CUSTOM_KEY"))
    }
}

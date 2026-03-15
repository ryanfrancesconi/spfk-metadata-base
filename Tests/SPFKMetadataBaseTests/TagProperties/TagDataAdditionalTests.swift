import Foundation
import Testing

@testable import SPFKMetadataBase

struct TagDataAdditionalTests {
    // MARK: - isEmpty

    @Test func isEmptyWhenBothEmpty() {
        let data = TagData()
        #expect(data.isEmpty)
    }

    @Test func isNotEmptyWithTags() {
        let data = TagData(tags: [.title: "Test"])
        #expect(!data.isEmpty)
    }

    @Test func isNotEmptyWithCustomTags() {
        let data = TagData(customTags: ["KEY": "Value"])
        #expect(!data.isEmpty)
    }

    @Test func isNotEmptyWithBoth() {
        let data = TagData(tags: [.title: "T"], customTags: ["K": "V"])
        #expect(!data.isEmpty)
    }

    // MARK: - Codable

    @Test func codableRoundTrip() throws {
        let original = TagData(
            tags: [.title: "Test Song", .album: "Test Album", .artist: "Test Artist"],
            customTags: ["CUSTOM1": "Value1", "CUSTOM2": "Value2"]
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(TagData.self, from: data)

        #expect(decoded == original)
        #expect(decoded.tags[.title] == "Test Song")
        #expect(decoded.customTags["CUSTOM1"] == "Value1")
    }

    @Test func codableEmpty() throws {
        let original = TagData()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(TagData.self, from: data)

        #expect(decoded.isEmpty)
    }

    // MARK: - Hashable

    @Test func hashable() {
        let data1 = TagData(tags: [.title: "Test"])
        let data2 = TagData(tags: [.title: "Test"])
        let data3 = TagData(tags: [.title: "Different"])

        #expect(data1.hashValue == data2.hashValue)
        #expect(data1 != data3)
    }

    // MARK: - remove(data:)

    @Test func removeSelectiveData() {
        var data = TagData(
            tags: [.title: "T1", .album: "A1", .artist: "Ar1"],
            customTags: ["K1": "V1", "K2": "V2", "K3": "V3"]
        )

        let toRemove = TagData(
            tags: [.title: "T1", .artist: "Ar1"],
            customTags: ["K1": "V1", "K3": "V3"]
        )

        data.remove(data: toRemove)

        #expect(data.tags.count == 1)
        #expect(data.tags[.album] == "A1")
        #expect(data.customTags.count == 1)
        #expect(data.customTags["K2"] == "V2")
    }

    // MARK: - merge schemes

    @Test func mergePreserve() {
        let data1 = TagData(tags: [.title: "First"])
        let data2 = TagData(tags: [.title: "Second"])

        let merged = [data1, data2].merge(scheme: .preserve)
        #expect(merged.tags[.title] == "First")
    }

    @Test func mergeReplace() {
        let data1 = TagData(tags: [.title: "First"])
        let data2 = TagData(tags: [.title: "Second"])

        let merged = [data1, data2].merge(scheme: .replace)
        #expect(merged.tags[.title] == "Second")
    }

    @Test func mergeCombine() {
        let data1 = TagData(tags: [.title: "A"])
        let data2 = TagData(tags: [.title: "B"])
        let data3 = TagData(tags: [.title: "C"])

        let merged = [data1, data2, data3].merge(scheme: .combine)
        #expect(merged.tags[.title] == "A, B, C")
    }

    @Test func mergeDisjointKeys() {
        let data1 = TagData(tags: [.title: "T"])
        let data2 = TagData(tags: [.album: "A"])

        let merged = [data1, data2].merge(scheme: .preserve)
        #expect(merged.tags[.title] == "T")
        #expect(merged.tags[.album] == "A")
    }

    // MARK: - init(labels:)

    @Test func labelsInitWithKnownTags() {
        let data = TagData(labels: [
            (label: "Title", value: "My Song"),
            (label: "Artist", value: "Someone"),
        ])

        #expect(data.tags[.title] == "My Song")
        #expect(data.tags[.artist] == "Someone")
        #expect(data.customTags.isEmpty)
    }

    @Test func labelsInitWithCustomTags() {
        let data = TagData(labels: [
            (label: "MY_CUSTOM_KEY", value: "custom value"),
        ])

        #expect(data.tags.isEmpty)
        #expect(data.customTags["MY_CUSTOM_KEY"] == "custom value")
    }

    @Test func labelsInitWithMixed() {
        let data = TagData(labels: [
            (label: "Album", value: "Test Album"),
            (label: "SOME_CUSTOM", value: "custom"),
            (label: "Genre", value: "Rock"),
        ])

        #expect(data.tags.count == 2)
        #expect(data.tags[.album] == "Test Album")
        #expect(data.tags[.genre] == "Rock")
        #expect(data.customTags.count == 1)
        #expect(data.customTags["SOME_CUSTOM"] == "custom")
    }

    @Test func labelsInitEmpty() {
        let data = TagData(labels: [])

        #expect(data.isEmpty)
    }

    @Test func labelsInitWithSpecialDisplayNames() {
        // Verify that overridden display names round-trip correctly
        let data = TagData(labels: [
            (label: "ISRC", value: "US1234567890"),
            (label: "Copyright URL", value: "https://example.com"),
            (label: "Loudness Integrated (LUFS)", value: "-14.0"),
        ])

        #expect(data.tags[.isrc] == "US1234567890")
        #expect(data.tags[.copyrightURL] == "https://example.com")
        #expect(data.tags[.loudnessIntegrated] == "-14.0")
        #expect(data.customTags.isEmpty)
    }

    @Test func labelsInitUpdatedViaReplace() {
        // Simulates the update flow: convert models → merge with replace
        let current = TagData(tags: [.title: "Old Title", .album: "My Album"])
        let changes = TagData(labels: [
            (label: "Title", value: "New Title"),
        ])

        let updated = [current, changes].merge(scheme: .replace)

        #expect(updated.tags[.title] == "New Title")
        #expect(updated.tags[.album] == "My Album")
    }

    @Test func labelsInitRemovedFromCurrent() {
        // Simulates the removal flow: convert models → remove from current
        var current = TagData(
            tags: [.title: "T", .album: "A", .artist: "Ar"],
            customTags: ["K1": "V1"]
        )

        let toRemove = TagData(labels: [
            (label: "Title", value: "T"),
            (label: "K1", value: "V1"),
        ])

        current.remove(data: toRemove)

        #expect(current.tags.count == 2)
        #expect(current.tags[.album] == "A")
        #expect(current.tags[.artist] == "Ar")
        #expect(current.customTags.isEmpty)
    }
}

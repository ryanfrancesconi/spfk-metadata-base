// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import Testing

@testable import SPFKMetadataBase

struct TagPropertiesTests {
    // MARK: - tagLibPropertyMap

    @Test func tagLibPropertyMapStandardTags() {
        var props = TagProperties()
        props.set(tag: .title, value: "My Title")
        props.set(tag: .artist, value: "My Artist")

        let map = props.tagLibPropertyMap

        #expect(map[TagKey.title.taglibKey] == "My Title")
        #expect(map[TagKey.artist.taglibKey] == "My Artist")
    }

    @Test(arguments: [
        (TagKey.encodedBy, "ENCODEDBY"),
        (TagKey.encodedBy, "encodedby"),
        (TagKey.copyrightURL, "COPYRIGHTURL"),
    ])
    func tagLibPropertyMapStandardTagWinsOverCustomOfSameName(key: TagKey, customKey: String) {
        var props = TagProperties()
        props.set(tag: key, value: "A")
        props.set(customTag: customKey, value: "B")

        #expect(props.tagLibPropertyMap[key.taglibKey] == "A")
    }

    @Test func tagLibPropertyMapCustomTags() {
        var props = TagProperties()
        props.set(customTag: "myCustomKey", value: "Custom Value")

        let map = props.tagLibPropertyMap

        // Custom tags are uppercased
        #expect(map["MYCUSTOMKEY"] == "Custom Value")
    }

    @Test func tagLibPropertyMapEmpty() {
        let props = TagProperties()
        #expect(props.tagLibPropertyMap.isEmpty)
    }

    // MARK: - merge

    @Test func mergeReplaceScheme() {
        var props = TagProperties()
        props.set(tag: .title, value: "Old Title")

        let newData = TagData(tags: [.title: "New Title"])
        props.merge(data: newData, scheme: .replace)

        #expect(props.tag(for: .title) == "New Title")
    }

    @Test func mergePreserveScheme() {
        var props = TagProperties()
        props.set(tag: .title, value: "Original")

        let newData = TagData(tags: [.title: "Replacement", .artist: "New Artist"])
        props.merge(data: newData, scheme: .preserve)

        #expect(props.tag(for: .title) == "Original")
        #expect(props.tag(for: .artist) == "New Artist")
    }

    @Test func mergeCombineScheme() {
        var props = TagProperties()
        props.set(tag: .genre, value: "Rock")

        let newData = TagData(tags: [.genre: "Pop"])
        props.merge(data: newData, scheme: .combine)

        let result = props.tag(for: .genre)
        #expect(result?.contains("Rock") == true)
        #expect(result?.contains("Pop") == true)
    }

    // MARK: - remove

    @Test func removeData() {
        var props = TagProperties()
        props.set(tag: .title, value: "Title")
        props.set(tag: .artist, value: "Artist")

        let toRemove = TagData(tags: [.title: ""])
        props.remove(data: toRemove)

        #expect(props.tag(for: .title) == nil)
        #expect(props.tag(for: .artist) == "Artist")
    }

    // MARK: - Codable

    @Test func codableRoundTrip() throws {
        var original = TagProperties()
        original.set(tag: .title, value: "Test Title")
        original.set(tag: .artist, value: "Test Artist")
        original.set(customTag: "MY_KEY", value: "Custom")

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(TagProperties.self, from: data)

        #expect(decoded.tag(for: .title) == "Test Title")
        #expect(decoded.tag(for: .artist) == "Test Artist")
        #expect(decoded.customTag(for: "MY_KEY") == "Custom")
    }

    @Test func codableEmptyRoundTrip() throws {
        let original = TagProperties()

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(TagProperties.self, from: data)

        #expect(decoded.data.isEmpty)
    }
}

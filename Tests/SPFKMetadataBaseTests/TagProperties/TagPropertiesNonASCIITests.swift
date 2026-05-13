// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import Testing

@testable import SPFKMetadataBase

struct TagPropertiesNonASCIITests {
    @Test func nonASCIITagRoundTrip() {
        var props = TagProperties()
        props.set(tag: .title, value: "für — Ångström")
        props.set(tag: .artist, value: "Björk")
        props.set(tag: .comment, value: "café résumé naïve")

        #expect(props.tag(for: .title) == "für — Ångström")
        #expect(props.tag(for: .artist) == "Björk")
        #expect(props.tag(for: .comment) == "café résumé naïve")
    }

    @Test func nonASCIIPassesThroughTagLibPropertyMap() {
        var props = TagProperties()
        props.set(tag: .title, value: "für — Ångström")
        props.set(tag: .artist, value: "Björk")

        let map = props.tagLibPropertyMap
        #expect(map[TagKey.title.taglibKey] == "für — Ångström")
        #expect(map[TagKey.artist.taglibKey] == "Björk")
    }

    @Test func nonASCIICustomTagPassesThroughTagLibPropertyMap() {
        var props = TagProperties()
        props.set(customTag: "myKey", value: "Ñoño: 日本語")

        let map = props.tagLibPropertyMap
        #expect(map["MYKEY"] == "Ñoño: 日本語")
    }

    @Test func nonASCIICodableRoundTrip() throws {
        var original = TagProperties()
        original.set(tag: .title, value: "für — Ångström")
        original.set(tag: .artist, value: "Björk")

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(TagProperties.self, from: data)

        #expect(decoded.tag(for: .title) == "für — Ångström")
        #expect(decoded.tag(for: .artist) == "Björk")
    }
}

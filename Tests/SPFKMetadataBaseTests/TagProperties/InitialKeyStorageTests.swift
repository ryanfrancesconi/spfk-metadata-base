// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKBase
import Testing

@testable import SPFKMetadataBase

@Suite("Initial key storage")
struct InitialKeyStorageTests {
    static let cases: [(typed: String, stored: String)] = [
        ("C# Minor", "C#m"),
        ("c#min", "C#m"),
        ("12A", "C#m"),
        ("C♯m", "C#m"),
        ("5m", "C#m"),
        ("Dbm", "Dbm"),
        ("db minor", "Dbm"),
        ("A Major", "A"),
        ("8B", "C"),
        ("o", "o"),
        ("O", "o"),
        ("off", "o"),
        ("Off Key", "o"),
        ("varies", "varies"),
        ("", ""),
    ]

    @Test(arguments: cases)
    func setInitialKeyStoresTheShortForm(typed: String, stored: String) {
        var properties = TagProperties()
        properties.setInitialKey(typed)
        #expect(properties.tag(for: .initialKey) == stored)
    }

    @Test(arguments: cases)
    func setTagStoresTheShortForm(typed: String, stored: String) {
        var data = TagData()
        data.set(tag: .initialKey, value: typed)
        #expect(data.tags[.initialKey] == stored)
    }

    @Test(arguments: cases)
    func theSubscriptStoresTheShortForm(typed: String, stored: String) {
        var data = TagData()
        data[.initialKey] = typed
        #expect(data.tags[.initialKey] == stored)
    }

    @Test func otherTagsAreStoredAsGiven() {
        var data = TagData()
        data[.title] = "C# Minor"
        data.set(tag: .comment, value: "8A")
        #expect(data[.title] == "C# Minor")
        #expect(data[.comment] == "8A")
    }

    @Test func nilStillRemovesTheKey() {
        var data = TagData()
        data[.initialKey] = "Am"
        data[.initialKey] = nil
        #expect(data[.initialKey] == nil)
        data.set(tag: .initialKey, value: "Am")
        data.set(tag: .initialKey, value: nil)
        #expect(data[.initialKey] == nil)
    }

    @Test func aParsedKeyIsKeptAsRead() {
        var properties = TagProperties()
        properties.set(taglibKey: TagKey.initialKey.taglibKey, value: "8A")
        #expect(properties.tag(for: .initialKey) == "8A")

        var id3 = TagProperties()
        id3.set(id3Frame: .initialKey, value: "C# Minor")
        #expect(id3.tag(for: .initialKey) == "C# Minor")
    }

    @Test func aSaveThatDoesNotSetTheKeyLeavesIt() {
        var properties = TagProperties()
        properties.set(taglibKey: TagKey.initialKey.taglibKey, value: "8A")
        properties.set(tag: .title, value: "Edited")
        properties[.artist] = "Someone"

        #expect(properties.tagLibPropertyMap[TagKey.initialKey.taglibKey] == "8A")
    }

    /// The entry points can normalize only the writes that reach them; `tags` itself is public.
    @Test func noSourceWritesTheKeyTagDirectly() throws {
        let sources = URL(filePath: #filePath)
            .deletingLastPathComponent() // TagProperties
            .deletingLastPathComponent() // SPFKMetadataBaseTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent()
            .appending(path: "Sources")

        let enumerator = try #require(FileManager.default.enumerator(at: sources, includingPropertiesForKeys: nil))
        let pattern = try Regex(#"tags\s*\[\s*\.initialKey\s*\]\s*=[^=]"#)
        var scanned = 0

        for case let url as URL in enumerator where url.pathExtension == "swift" {
            scanned += 1
            guard !url.lastPathComponent.hasPrefix("TagPropertiesContainerModel") else { continue }

            let text = try String(contentsOf: url, encoding: .utf8)
            #expect(text.firstMatch(of: pattern) == nil, "\(url.lastPathComponent) writes tags[.initialKey]")
        }

        #expect(scanned > 40)
    }
}

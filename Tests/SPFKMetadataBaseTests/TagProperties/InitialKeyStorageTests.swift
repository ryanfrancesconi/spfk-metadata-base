// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKAudioBase
import SPFKBase
import SPFKTesting
import Testing

@testable import SPFKMetadataBase

@Suite("Initial key storage", .tags(.musicalKey))
struct InitialKeyStorageTests {
    static let cases: [(typed: String, stored: String)] = [
        ("C# Minor", "C# Minor"),
        ("c#min", "C# Minor"),
        ("12A", "C# Minor"),
        ("C♯m", "C# Minor"),
        ("5m", "C# Minor"),
        ("Dbm", "Db Minor"),
        ("db minor", "Db Minor"),
        ("A Major", "A Major"),
        ("Amaj", "A Major"),
        ("4B", "Ab Major"),
        ("8B", "C Major"),
        ("A", "A"),
        ("F#", "F#"),
        ("B♭", "Bb"),
        ("o", "o"),
        ("O", "o"),
        ("off", "o"),
        ("Off Key", "o"),
        ("varies", "varies"),
        ("", ""),
    ]

    @Test(arguments: cases)
    func setTagStoresTheStandardNotation(typed: String, stored: String) {
        var data = TagData()
        data.set(tag: .initialKey, value: typed)
        #expect(data.tags[.initialKey] == stored)
    }

    @Test(arguments: cases)
    func theSubscriptStoresTheStandardNotation(typed: String, stored: String) {
        var data = TagData()
        data[.initialKey] = typed
        #expect(data.tags[.initialKey] == stored)
    }

    @Test(arguments: [
        ("C# Minor", MusicalKeyNotation.short, "C#m"),
        ("Dbm", .short, "Dbm"),
        ("A Major", .short, "Amaj"),
        ("Abmin", .camelot, "1A"),
        ("8A", .openKey, "1m"),
        ("1m", .camelot, "8A"),
        ("C# Minor", .standard, "C# Minor"),
    ])
    func setInitialKeyStoresTheNotationAsked(typed: String, notation: MusicalKeyNotation, stored: String) {
        var properties = TagProperties()
        properties.setInitialKey(typed, notation: notation)
        #expect(properties.tag(for: .initialKey) == stored)
    }

    @Test(arguments: MusicalKeyNotation.allCases)
    func offKeyIsOInEveryNotation(notation: MusicalKeyNotation) {
        var properties = TagProperties()
        properties.setInitialKey("Off Key", notation: notation)
        #expect(properties.tag(for: .initialKey) == "o")
    }

    @Test(arguments: [MusicalKeyNotation.camelot, .openKey])
    func aRootAloneFallsBackToStandardOnAWheel(notation: MusicalKeyNotation) {
        var properties = TagProperties()
        properties.setInitialKey("f#", notation: notation)
        #expect(properties.tag(for: .initialKey) == "F#")
    }

    @Test func aRootAloneReadsBackAsARootAlone() throws {
        var data = TagData()
        data[.initialKey] = "F#"
        let stored = try #require(data[.initialKey])
        let parsed = try #require(MusicalKeyValue.parse(stored))
        #expect(parsed.value.tonality == .unknown)
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
    /// Scans every package beside this one, so a writer anywhere in the workspace is caught.
    @Test func noSourceWritesTheKeyTagDirectly() throws {
        let packages = URL(filePath: #filePath)
            .deletingLastPathComponent() // TagProperties
            .deletingLastPathComponent() // SPFKMetadataBaseTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // spfk-metadata-base
            .deletingLastPathComponent()

        let patterns = try [
            Regex(#"tags\s*\[\s*\.initialKey\s*\]\s*=[^=]"#),
            Regex(#"\(tags:\s*\[[^\]]*\.initialKey\s*:"#),
        ]

        let packageURLs = try FileManager.default.contentsOfDirectory(at: packages, includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.hasPrefix("spfk-") }

        var scanned: [String: Int] = [:]

        for package in packageURLs {
            let sources = package.appending(path: "Sources")

            guard let enumerator = FileManager.default.enumerator(
                at: sources, includingPropertiesForKeys: nil, options: .skipsHiddenFiles
            ) else { continue }

            for case let url as URL in enumerator where url.pathExtension == "swift" {
                scanned[package.lastPathComponent, default: 0] += 1
                guard !url.lastPathComponent.hasPrefix("TagPropertiesContainerModel") else { continue }

                let text = try String(contentsOf: url, encoding: .utf8)

                for pattern in patterns {
                    #expect(text.firstMatch(of: pattern) == nil, "\(url.lastPathComponent) writes the key tag directly")
                }
            }
        }

        #expect(scanned["spfk-metadata-base", default: 0] > 40)
    }
}

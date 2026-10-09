// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKAudioBase
import Testing

@testable import SPFKMetadataBase

/// A failed read outlives the description's trip through storage, so the save stays refused.
@Suite
final class MetadataReadStatusCodingTests {
    private let url = URL(fileURLWithPath: "/tmp/read-status.mp3")

    private func roundTrip(_ description: MetaAudioFileDescription) throws -> MetaAudioFileDescription {
        try JSONDecoder().decode(MetaAudioFileDescription.self, from: JSONEncoder().encode(description))
    }

    @Test func aFailedReadSurvivesARoundTrip() throws {
        var description = MetaAudioFileDescription(url: url, fileType: .mp3)
        description.readStatus.failed = [.tags, .markers]

        #expect(try roundTrip(description).readStatus.failed == [.tags, .markers])
    }

    /// Every stored description, and every one whose reads succeeded, has no key at all.
    @Test func aCleanStatusWritesNoKey() throws {
        let data = try JSONEncoder().encode(MetaAudioFileDescription(url: url, fileType: .mp3))
        let object = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(object["readFailures"] == nil)
    }

    @Test func aDescriptionStoredWithoutTheKeyDecodesClean() throws {
        let data = try JSONEncoder().encode(MetaAudioFileDescription(url: url, fileType: .mp3))
        let decoded = try JSONDecoder().decode(MetaAudioFileDescription.self, from: data)

        #expect(decoded.readStatus.failed.isEmpty)
    }

    /// The status encodes itself, in declaration order whatever order it was built in, so both
    /// products' descriptions store the same form.
    @Test func theStatusEncodesAsItsComponentNamesInOrder() throws {
        let status = MetadataReadStatus(failed: [.xmp, .tags, .markers])
        let data = try JSONEncoder().encode(status)

        #expect(try JSONDecoder().decode([String].self, from: data) == ["tags", "markers", "xmp"])
        #expect(try JSONDecoder().decode(MetadataReadStatus.self, from: data) == status)
    }

    /// The stored names are on-disk format: a renamed case would turn a refused save into a decode
    /// failure for every row holding it.
    @Test func eachComponentKeepsItsStoredName() throws {
        let expected: [(MetadataComponent, String)] = [
            (.tags, "tags"), (.rating, "rating"), (.artwork, "artwork"), (.markers, "markers"),
            (.bext, "bext"), (.ixml, "ixml"), (.xmp, "xmp"), (.finderTags, "finderTags"),
        ]

        #expect(expected.map(\.0) == MetadataComponent.allCases)

        for (component, name) in expected {
            #expect(component.rawValue == name)
        }
    }
}

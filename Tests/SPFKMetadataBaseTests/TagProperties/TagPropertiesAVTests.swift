// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKTesting
import Testing

@testable import SPFKMetadataBase

@Suite(.tags(.file))
struct TagPropertiesAVTests {
    /// The expected title is whatever AVFoundation itself reports for the file's TIT2 frame.
    @Test func readsTheTitleFrame() async throws {
        let url = TestBundleResources.shared.mp3_id3

        let probe = try await TagPropertiesAV.probe(url: url)
        let title = try #require(probe.items.first { $0.identifier?.hasSuffix("TIT2") == true }?.value)
        #expect(title.isNotEmpty)

        let properties = try await TagPropertiesAV(url: url)
        #expect(properties.data.tags[.title] == title)
    }
}

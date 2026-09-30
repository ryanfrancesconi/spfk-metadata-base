// Copyright Ryan Francesconi. All Rights Reserved.

import CoreImage
import Foundation
import SPFKImage
import SPFKTesting
import Testing

@testable import SPFKMetadataBase

@Suite(.tags(.file))
struct ImageDescriptionTests {
    /// Artwork is left out of `==`, so it has to be left out of the hash too.
    @Test func equalDescriptionsHashEqually() async throws {
        var a = ImageDescription()
        a.description = "Front"

        var b = a
        await b.update(cgImage: try CGImage.contentsOf(url: TestBundleResources.shared.sharksandwich))

        #expect(a == b)
        #expect(a.hashValue == b.hashValue)
        #expect(Set([a, b]).count == 1)
    }

    @Test func image() async throws {
        let cgImage = try CGImage.contentsOf(url: TestBundleResources.shared.sharksandwich)
        var desc = ImageDescription()
        await desc.update(cgImage: cgImage)

        let thumbnailImage = try #require(desc.thumbnailImage)

        #expect(thumbnailImage.width == 64)
        #expect(thumbnailImage.height == 64)
    }
}

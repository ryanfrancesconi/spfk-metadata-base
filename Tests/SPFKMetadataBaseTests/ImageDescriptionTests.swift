// Copyright Ryan Francesconi. All Rights Reserved.

import CoreImage
import Foundation
import SPFKImage
import SPFKTesting
import Testing

@testable import SPFKMetadataBase

@Suite(.tags(.file))
struct ImageDescriptionTests {
    @Test func image() async throws {
        let cgImage = try CGImage.contentsOf(url: TestBundleResources.shared.sharksandwich)
        var desc = ImageDescription()
        await desc.update(cgImage: cgImage)

        let thumbnailImage = try #require(desc.thumbnailImage)

        #expect(thumbnailImage.width == 64)
        #expect(thumbnailImage.height == 64)
    }
}

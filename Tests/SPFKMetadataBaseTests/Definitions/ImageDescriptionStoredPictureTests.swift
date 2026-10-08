// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import CoreGraphics
import Foundation
import Testing

@testable import SPFKMetadataBase

/// The stored bytes describe one image: they survive while that image is kept, and go when it is replaced.
struct ImageDescriptionStoredPictureTests {
    private func image() throws -> CGImage {
        let context = try #require(CGContext(
            data: nil, width: 4, height: 4, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue
        ))
        return try #require(context.makeImage())
    }

    private let picture = ImageDescription.StoredPicture(data: Data([1, 2, 3]), mimeType: "image/jpeg")

    @Test func theStoredBytesStayWithTheirImage() throws {
        let original = try image()
        var description = ImageDescription()
        description.setImage(original, storedAs: picture)

        description.cgImage = original

        #expect(description.storedPicture == picture)
    }

    @Test func anotherImageDropsTheStoredBytes() throws {
        var description = ImageDescription()
        description.setImage(try image(), storedAs: picture)

        description.cgImage = try image()

        #expect(description.storedPicture == nil)
    }

    @Test func removingTheImageDropsTheStoredBytes() throws {
        var description = ImageDescription()
        description.setImage(try image(), storedAs: picture)

        description.cgImage = nil

        #expect(description.storedPicture == nil)
    }
}

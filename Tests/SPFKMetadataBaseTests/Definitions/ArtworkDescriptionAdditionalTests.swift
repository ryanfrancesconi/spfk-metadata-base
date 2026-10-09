import Foundation
import Testing

@testable import SPFKMetadataBase

struct ArtworkDescriptionCodableTests {
    @Test func codableRoundTripEmpty() throws {
        let original = ArtworkDescription()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ArtworkDescription.self, from: data)

        #expect(decoded.thumbnailData == nil)
        #expect(decoded.description == nil)
        #expect(decoded.cgImage == nil)
    }

    @Test func codableWithDescription() throws {
        var original = ArtworkDescription()
        original.description = "Album art"

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ArtworkDescription.self, from: data)

        #expect(decoded.description == "Album art")
    }

    @Test func codableWithThumbnailData() throws {
        var original = ArtworkDescription()
        original.description = "Test"

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ArtworkDescription.self, from: data)

        // cgImage is deliberately not encoded
        #expect(decoded.cgImage == nil)
        #expect(decoded.description == "Test")
    }
}

struct ArtworkDescriptionEquatableTests {
    @Test func equalWhenBothEmpty() {
        let a = ArtworkDescription()
        let b = ArtworkDescription()
        #expect(a == b)
    }

    @Test func equalWithSameDescription() {
        var a = ArtworkDescription()
        a.description = "Test"
        var b = ArtworkDescription()
        b.description = "Test"
        #expect(a == b)
    }

    @Test func notEqualDifferentDescription() {
        var a = ArtworkDescription()
        a.description = "A"
        var b = ArtworkDescription()
        b.description = "B"
        #expect(a != b)
    }
}

struct ArtworkDescriptionInitTests {
    @Test func defaultInit() {
        let desc = ArtworkDescription()
        #expect(desc.cgImage == nil)
        #expect(desc.thumbnailImage == nil)
        #expect(desc.thumbnailData == nil)
        #expect(desc.description == nil)
    }
}

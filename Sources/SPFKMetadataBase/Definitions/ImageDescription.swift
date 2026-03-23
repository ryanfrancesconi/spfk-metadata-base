import CoreImage
import Foundation
import SPFKUtils

/// Container for embedded audio file artwork with thumbnail generation.
///
/// The full-resolution `CGImage` and thumbnail image are transient — excluded from `Codable`.
/// Only the text ``description`` is serialized. Image data is persisted via `ImageDataStore`.
public struct ImageDescription: Sendable, Hashable {
    /// The full-resolution embedded artwork. Not encoded.
    public var cgImage: CGImage?

    /// A downscaled thumbnail of the artwork, created from ``thumbnailData`` or set via ``setThumbnailImage(_:)``.
    public private(set) var thumbnailImage: CGImage?

    /// PNG data of the thumbnail image, populated in-memory by ``createThumbnail()``.
    public private(set) var thumbnailData: Data?

    /// Optional text description of the image (e.g., "Front Cover").
    public var description: String?

    public init() {}

    /// Generates a small PNG thumbnail from the current ``cgImage`` and stores it in ``thumbnailData``.
    public mutating func createThumbnail() async {
        guard let cgImage else {
            return
        }

        thumbnailData = await Self.createThumbnail(cgImage: cgImage)
        updateThumbnail()
    }

    /// Recreates ``thumbnailImage`` from the current ``thumbnailData``.
    public mutating func updateThumbnail() {
        if let thumbnailData {
            thumbnailImage = try? CGImage.create(from: thumbnailData)
        }
    }

    /// Sets the thumbnail image directly, for use when hydrating from the image cache.
    public mutating func setThumbnailImage(_ image: CGImage?) {
        thumbnailImage = image
    }
}

// MARK: - Equatable

extension ImageDescription: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.description == rhs.description
    }
}

// MARK: - Codable

extension ImageDescription: Codable {
    enum CodingKeys: String, CodingKey {
        case description
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        // thumbnailImage is populated separately from the image cache after decode
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(description, forKey: .description)
    }
}

extension ImageDescription {
    /// Creates a PNG thumbnail of the given image, scaled to the specified size.
    /// Returns `nil` if the source image is too small (< 64px in either dimension).
    public static func createThumbnail(cgImage: CGImage, size: CGSize = .init(equal: 32)) async -> Data? {
        let task = Task<Data?, Error>(priority: .userInitiated) {
            guard cgImage.width > 64, cgImage.height > 64,
                let rescaledImage = cgImage.scaled(to: size)
            else { return nil }

            return rescaledImage.pngRepresentation
        }

        return try? await task.value
    }

    /// Replaces the current artwork and regenerates the thumbnail.
    public mutating func update(cgImage: CGImage) async {
        self.cgImage = cgImage
        await createThumbnail()
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import AVFoundation
import Foundation

/// Read-only tag reader using AVFoundation instead of TagLib.
///
/// Parses ID3 metadata via `AVURLAsset` without any native library dependencies. Write support
/// is not available through AVFoundation. Slower than ``TagProperties`` due to AVFoundation's
/// asynchronous loading model. Useful as a fallback or when TagLib is not needed.
public struct TagPropertiesAV: Hashable, Codable, Sendable {
    /// The parsed tag data.
    public var data = TagData()

    /// Reads ID3 tags from the audio file at the given URL using AVFoundation.
    /// - Parameter url: URL to the audio file.
    public init(url: URL) async throws {
        let asset = AVURLAsset(url: url)

        let metadata = try await Self.loadMetadata(from: asset)

        for item in metadata {
            guard let id3key = item.key as? String,
                let id3Frame = ID3FrameKey(rawValue: id3key),
                let value = try? await Self.loadValue(for: item)
            else { continue }

            data.set(id3Frame: id3Frame, value: value)
        }
    }

    private static func loadMetadata(from asset: AVURLAsset) async throws -> [AVMetadataItem] {
        try await asset.loadMetadata(for: .id3Metadata)
    }

    private static func loadValue(for item: AVMetadataItem) async throws -> String? {
        try await item.load(.value) as? String
    }
}

// MARK: - Probing

/// One metadata item exactly as the file declares it, before any mapping into a tag vocabulary.
///
/// Deliberately strings and no ``TagKey``: the point is to see what a container carries, including
/// the keyspaces that have no tag equivalent at all. `AVMetadataItem` is not `Sendable`, so this
/// carries the values out rather than the items.
public struct AVMetadataProbeItem: Hashable, Sendable {
    /// The keyspace the item came from, e.g. `org.smpte.mxf`, `org.id3`, `com.apple.quicktime.mdta`.
    public let format: String

    public let identifier: String?

    /// AVFoundation's cross-format key (`title`, `artist`, …) when the item maps to one. Empty for
    /// a keyspace with no common equivalent, which is what makes a container untaggable.
    public let commonKey: String?

    public let value: String?
}

/// What a container actually carries, per keyspace.
public struct AVMetadataProbe: Hashable, Sendable {
    /// Every keyspace the file declares, including any that yielded no items.
    public let formats: [String]

    public let items: [AVMetadataProbeItem]

    /// Whether anything maps to AVFoundation's common keys. `false` means the file states no
    /// title, artist or description **in terms any format-independent reader can use** -- true of
    /// MXF, whose whole keyspace is provenance.
    public var hasCommonKeys: Bool {
        items.contains { $0.commonKey != nil }
    }
}

public extension TagPropertiesAV {
    /// Reads every metadata keyspace the file declares, rather than one named in advance.
    ///
    /// ``init(url:)`` asks only for ID3, so it returns nothing for a container whose metadata
    /// lives elsewhere -- a `.mov` and an `.mxf` both come back empty through it while carrying
    /// items. This answers "what is actually in here", which is the question worth asking before
    /// deciding whether a format is taggable at all.
    ///
    /// Read-only, like the rest of this type: AVFoundation offers no write path for any of it.
    static func probe(url: URL) async throws -> AVMetadataProbe {
        let asset = AVURLAsset(url: url)
        let formats = try await asset.load(.availableMetadataFormats)

        var items: [AVMetadataProbeItem] = []

        for format in formats {
            for item in try await asset.loadMetadata(for: format) {
                items.append(
                    AVMetadataProbeItem(
                        format: format.rawValue,
                        identifier: item.identifier?.rawValue,
                        commonKey: item.commonKey?.rawValue,
                        value: await Self.describe(item)
                    )
                )
            }
        }

        return AVMetadataProbe(formats: formats.map(\.rawValue), items: items)
    }

    /// `stringValue` first, since it converts numbers and dates; a binary value (a UMID) has none
    /// and is described instead so it still appears rather than reading as absent.
    private static func describe(_ item: AVMetadataItem) async -> String? {
        if let string = try? await item.load(.stringValue) {
            return string
        }

        guard let value = try? await item.load(.value) else { return nil }

        return String(describing: value)
    }
}

extension TagPropertiesAV: TagPropertiesContainerModel {
    public var tags: TagKeyDictionary {
        get { data.tags }
        set { data.tags = newValue }
    }

    public var customTags: [String: String] {
        get { data.customTags }
        set { data.customTags = newValue }
    }
}

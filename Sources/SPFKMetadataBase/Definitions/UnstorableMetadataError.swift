// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKAudioBase

/// A save asked for changes the file's container has no writer for. Retrying cannot succeed.
public struct UnstorableMetadataError: LocalizedError, Hashable, Sendable {
    public let fileType: AudioFileType?

    /// The requested flags the container cannot store: `.metadata`, `.image` or `.markers`.
    public let flags: Set<MetadataDirtyFlag>

    public init(fileType: AudioFileType?, flags: Set<MetadataDirtyFlag>) {
        self.fileType = fileType
        self.flags = flags
    }

    public var errorDescription: String? {
        let name = fileType?.pathExtension.uppercased() ?? "These"
        let what = flags == [.markers] ? "markers" : "metadata"
        return "\(name) files can't store \(what)"
    }
}

extension MetaAudioFileDescription {
    /// Whether tags, BEXT, iXML and artwork can be written into this file.
    public var canStoreTags: Bool {
        capabilityFileType?.supportsMetadata == true
    }

    public var canStoreMarkers: Bool {
        capabilityFileType?.supportsMarkerWrite == true
    }

    /// Falls back to the extension for a description not yet parsed, which has no `fileType`.
    private var capabilityFileType: AudioFileType? {
        fileType ?? AudioFileType(pathExtension: url.pathExtension)
    }

    /// The subset of `dirtyFlags` this file's container cannot store.
    public func unstorableFlags(in dirtyFlags: Set<MetadataDirtyFlag>) -> Set<MetadataDirtyFlag> {
        var result = Set<MetadataDirtyFlag>()

        if !canStoreTags {
            result.formUnion(dirtyFlags.intersection([.metadata, .image]))
        }

        if !canStoreMarkers, dirtyFlags.contains(.markers) {
            result.insert(.markers)
        }

        return result
    }
}

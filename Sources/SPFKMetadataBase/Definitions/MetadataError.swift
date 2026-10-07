// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKAudioBase

/// A metadata read or write that failed, naming which part of the file it was for.
///
/// A save asking for something the container cannot store throws `UnstorableMetadataError`, and a
/// locked file `FileLockError`; neither is a case here.
public enum MetadataError: LocalizedError, Hashable, Sendable {
    /// The part of a file's metadata an operation addressed.
    public enum Component: Hashable, Sendable {
        case tags
        case rating
        case artwork
        case markers
        case bext
        case ixml
        case xmpPacket
    }

    /// No reader or writer exists for this type, or the type could not be determined (`nil`).
    case unsupportedFormat(AudioFileType?, Component)
    case readFailed(Component, URL)
    case writeFailed(Component, URL)
    case copyFailed(Component, from: URL, to: URL)
    case removeFailed(Component, URL)

    public var errorDescription: String? {
        switch self {
        case let .unsupportedFormat(fileType, component):
            guard let fileType else { return "Unable to determine the file type for \(component.noun)" }
            return "Unsupported file type for \(component.noun): \(fileType.pathExtension.uppercased())"

        case let .readFailed(.tags, url):
            return "Failed to load tag file: \(url.path)"

        case let .readFailed(component, url):
            return "Failed to read \(component.noun) from \(url.path)"

        case let .writeFailed(.tags, url):
            return "Failed to update tags in \(url.path)"

        case let .writeFailed(component, url):
            return "Failed to write \(component.noun) to \(url.path)"

        case let .copyFailed(component, source, destination):
            return "Failed to copy \(component.noun) from \(source.path) to \(destination.path)"

        case let .removeFailed(.tags, url):
            return "Failed to removeAll tags in \(url.path)"

        case let .removeFailed(component, url):
            return "Failed to remove \(component.noun) from \(url.path)"
        }
    }
}

extension MetadataError.Component {
    /// The wording `MetadataError.errorDescription` uses mid-sentence.
    var noun: String {
        switch self {
        case .tags: "tags"
        case .rating: "the rating"
        case .artwork: "artwork"
        case .markers: "markers"
        case .bext: "BEXT chunk"
        case .ixml: "iXML chunk"
        case .xmpPacket: "the XMP packet"
        }
    }
}

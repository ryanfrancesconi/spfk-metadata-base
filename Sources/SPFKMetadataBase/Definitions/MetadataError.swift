// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKAudioBase

/// A metadata read or write that failed, naming which part of the file it was for.
///
/// A save throws ``incompleteSave(written:failures:)`` for what it left out, and a locked file
/// `FileLockError`, which is not a case here.
public enum MetadataError: LocalizedError, Hashable, Sendable {
    /// No reader or writer exists for this type, or the type could not be determined (`nil`).
    case unsupportedFormat(AudioFileType?, MetadataComponent)
    /// Also thrown by a save for a component the parse could not read, which the save leaves as
    /// the file has it (`MetaAudioFileDescription.readStatus`).
    case readFailed(MetadataComponent, URL)
    case writeFailed(MetadataComponent, URL)
    case copyFailed(MetadataComponent, from: URL, to: URL)
    case removeFailed(MetadataComponent, URL)
    /// The container has no writer for these flags (`.metadata`, `.image` or `.markers`). Retrying
    /// cannot succeed.
    case unstorable(AudioFileType?, Set<MetadataDirtyFlag>)
    /// A save that wrote `written` and left the rest as the file has it, each part for the reason in
    /// `failures`: not read, not written, or `unstorable`. `written` may be empty.
    case incompleteSave(written: Set<MetadataDirtyFlag>, failures: [MetadataError])

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

        case let .unstorable(fileType, flags):
            let name = fileType?.pathExtension.uppercased() ?? "These"
            let what = flags == [.markers] ? "markers" : "metadata"
            return "\(name) files can't store \(what)"

        case let .incompleteSave(_, failures):
            return failures.compactMap(\.errorDescription).joined(separator: "; ")
        }
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation

/// A part of a file's metadata that is read and written on its own.
///
/// Stored by both products' libraries (``MetadataReadStatus``): the names are a storage format, and
/// so is the declaration order (a bitmask). Append a case; never rename or move one.
public enum MetadataComponent: String, CaseIterable, Codable, Hashable, Sendable {
    case tags
    case rating
    case artwork
    case markers
    case bext
    case ixml
    case xmp
    /// The Finder tags and modification date, kept in the file system rather than in the file.
    /// Never a read failure: they are read with the file's other resource values.
    case finderTags
}

extension MetadataComponent {
    /// The dirty flag whose save writes this component.
    public var dirtyFlag: MetadataDirtyFlag {
        switch self {
        case .tags, .rating, .bext, .ixml: .tags
        case .artwork: .artwork
        case .markers: .markers
        case .xmp: .xmp
        case .finderTags: .finderTags
        }
    }

    /// The wording `MetadataError.errorDescription` uses mid-sentence.
    var noun: String {
        switch self {
        case .tags: "tags"
        case .rating: "the rating"
        case .artwork: "artwork"
        case .markers: "markers"
        case .bext: "BEXT chunk"
        case .ixml: "iXML chunk"
        case .xmp: "the XMP packet"
        case .finderTags: "Finder tags"
        }
    }
}

extension MetadataDirtyFlag {
    /// The components a save of this flag writes.
    public var components: [MetadataComponent] {
        MetadataComponent.allCases.filter { $0.dirtyFlag == self }
    }

    /// Whether a save that wrote `written` wrote every component of this flag, so it may be cleared.
    public func isFullyWritten(by written: Set<MetadataComponent>) -> Bool {
        components.allSatisfy(written.contains)
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation

/// A part of a file's metadata that is read and written on its own.
///
/// Stored by `MetaAudioFileDescription.readStatus`: the names are a storage format, and so is
/// the declaration order (a bitmask in ShadowTag's library). Append a case; never rename or move one.
public enum MetadataComponent: String, CaseIterable, Codable, Hashable, Sendable {
    case tags
    case rating
    case artwork
    case markers
    case bext
    case ixml
    case xmp
}

extension MetadataComponent {
    /// The dirty flag whose save writes this component.
    public var dirtyFlag: MetadataDirtyFlag {
        switch self {
        case .tags, .rating, .bext, .ixml: .metadata
        case .artwork: .image
        case .markers: .markers
        case .xmp: .xmp
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
        }
    }
}

extension MetadataDirtyFlag {
    /// The components a save of this flag writes; none for `.finderTags`, which is not in the file.
    public var components: [MetadataComponent] {
        MetadataComponent.allCases.filter { $0.dirtyFlag == self }
    }
}

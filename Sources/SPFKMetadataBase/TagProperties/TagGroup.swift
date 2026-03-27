// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata

import Foundation

/// Logical grouping of ``TagKey`` values for organizing tag display in UI (e.g., common, music, loudness).
public enum TagGroup: CaseIterable, Hashable, Sendable {
    case common
    case music
    case ucs
    case loudness
    case replayGain
    case utility
    case other

    /// Human-readable section title for UI display.
    public var title: String {
        switch self {
        case .common: "Common"
        case .music: "Musical"
        case .ucs: "UCS"
        case .loudness: "Loudness"
        case .replayGain: "Replay Gain"
        case .utility: "Utility"
        case .other: "Other"
        }
    }

    /// The ``TagKey`` values belonging to this group.
    public var keys: [TagKey] {
        TagGroup.keysByGroup[self, default: []]
    }

    public init?(title: String) {
        for item in Self.allCases where item.title == title {
            self = item
            return
        }
        return nil
    }
}

extension TagGroup {
    /// Cached mapping of all ``TagKey`` cases grouped by their ``TagGroup``, built once on first access.
    private static let keysByGroup: [TagGroup: [TagKey]] =
        Dictionary(grouping: TagKey.allCases, by: { $0.tagGroup })
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation

/// Structural classification of an audio marker.
///
/// The raw values are persisted; renaming a case is a data migration.
public enum AudioMarkerType: String, Codable, Sendable, CaseIterable {
    /// A point marker — `endTime` is nil.
    case cue

    /// A region marker — has both `startTime` and `endTime`.
    /// Used for chapters, extraction regions, and any other start/end annotation.
    case region

    /// A detection preview region — runtime only; callers filter it out before a write.
    /// Rendered with reduced opacity to distinguish from committed `.region` markers.
    /// Promoted to `.region` when the user confirms via "Write Markers".
    case pendingRegion
}

extension AudioMarkerType {
    public var isRegion: Bool {
        self == .region || self == .pendingRegion
    }
}

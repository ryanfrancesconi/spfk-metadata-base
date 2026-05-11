// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi

import Foundation

/// Structural classification of an audio marker.
public enum AudioMarkerType: String, Codable, Sendable, CaseIterable {
    /// A point marker — `endTime` is nil.
    case cue

    /// A region marker — has both `startTime` and `endTime`.
    /// Used for chapters, extraction regions, and any other start/end annotation.
    case region
}

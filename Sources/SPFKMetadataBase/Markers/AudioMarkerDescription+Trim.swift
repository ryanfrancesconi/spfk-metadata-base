// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation

extension AudioMarkerDescription {
    /// Maps markers from a source timeline onto the timeline a trim produces.
    ///
    /// Markers outside the kept range are dropped, and the rest shift back by `inPoint` so they
    /// keep pointing at the same audio. A region whose end falls past the kept range is clamped to
    /// `newDuration` when one is given — an end beyond the file's own duration is not a position
    /// anything can resolve.
    ///
    /// - Parameters:
    ///   - inPoint: start of the kept range, in source-timeline seconds.
    ///   - outPoint: end of the kept range; `0` means "keep to the end", matching `TrimDescription`.
    ///   - newDuration: duration of the trimmed file. Pass `nil` to leave region ends unclamped.
    public static func adjustedForTrim(
        _ descriptions: [AudioMarkerDescription],
        inPoint: TimeInterval,
        outPoint: TimeInterval,
        newDuration: TimeInterval? = nil
    ) -> [AudioMarkerDescription] {
        descriptions.compactMap { description in
            guard description.startTime >= inPoint else { return nil }
            if outPoint > 0, description.startTime >= outPoint { return nil }

            var copy = description
            copy.startTime = max(0, description.startTime - inPoint)

            if let end = description.endTime {
                let shifted = max(0, end - inPoint)
                copy.endTime = newDuration.map { min(shifted, $0) } ?? shifted
            }

            return copy
        }
    }
}

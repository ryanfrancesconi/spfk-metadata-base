// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKBase

extension AudioMarkerDescription {
    /// Maps markers from a source timeline onto the timeline a trim produces.
    ///
    /// The kept range is half-open: a marker on `inPoint` survives and lands at 0, one on
    /// `outPoint` is dropped. A region overlapping the range is kept and clipped to it, so a
    /// region straddling `inPoint` starts at 0 rather than disappearing. A region's end is bounded
    /// by `newDuration` when one is given — an end beyond the file's own duration is not a
    /// position anything can resolve.
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
        adjusted(descriptions, inPoint: inPoint, outPoint: outPoint, timeScale: 1, newDuration: newDuration)
    }

    /// Maps markers onto the timeline a render produces: the trim of ``adjustedForTrim(_:inPoint:outPoint:newDuration:)``,
    /// then every time divided by `timeScale`, the render's playback rate (2 halves every time).
    /// `newDuration` is the rendered file's, in its own timeline.
    public static func adjusted(
        _ descriptions: [AudioMarkerDescription],
        forTrim trim: TrimDescription,
        timeScale: Double,
        newDuration: TimeInterval? = nil
    ) -> [AudioMarkerDescription] {
        adjusted(descriptions, inPoint: trim.inPoint, outPoint: trim.outPoint, timeScale: timeScale, newDuration: newDuration)
    }

    private static func adjusted(
        _ descriptions: [AudioMarkerDescription],
        inPoint: TimeInterval,
        outPoint: TimeInterval,
        timeScale: Double,
        newDuration: TimeInterval?
    ) -> [AudioMarkerDescription] {
        let scale = timeScale.isFinite && timeScale > 0 ? timeScale : 1

        return descriptions.compactMap { description in
            // A point marker has only its start to place it; a region also survives on its end,
            // which is what keeps one spanning the in-point from being thrown away.
            let overlapsInPoint = description.startTime >= inPoint
                || (description.endTime.map { $0 > inPoint } ?? false)

            guard overlapsInPoint else { return nil }
            if outPoint > 0, description.startTime >= outPoint { return nil }

            var copy = description
            copy.startTime = max(0, description.startTime - inPoint) / scale

            if let end = description.endTime {
                let shifted = max(0, end - inPoint) / scale
                copy.endTime = newDuration.map { min(shifted, $0) } ?? shifted
            }

            return copy
        }
    }
}

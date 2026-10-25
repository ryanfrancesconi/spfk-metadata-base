// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKAudioBase
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

    /// Maps markers onto the timeline a render of `edit` produces: the trim of
    /// ``adjustedForTrim(_:inPoint:outPoint:newDuration:)``, every time divided by the edit's rate
    /// (2 halves every time), then, for a reversed edit, mirrored with region ends swapped.
    /// `newDuration` is the rendered file's, in its own timeline.
    public static func adjusted(
        _ descriptions: [AudioMarkerDescription],
        for edit: AudioEditDescription,
        newDuration: TimeInterval
    ) -> [AudioMarkerDescription] {
        let adjusted = adjusted(
            descriptions,
            inPoint: edit.trim.inPoint,
            outPoint: edit.trim.outPoint,
            timeScale: edit.timePitch.rate,
            newDuration: newDuration
        )
        return edit.isReversed ? mirrored(adjusted, duration: newDuration) : adjusted
    }

    /// Markers on the reversed timeline of a file `duration` seconds long: t → duration − t, with
    /// each region's start and end swapped, in ascending start order. A chapter writer expects
    /// that order, and a mirror reverses it.
    public static func mirrored(_ descriptions: [AudioMarkerDescription], duration: TimeInterval) -> [AudioMarkerDescription] {
        let mirrored = descriptions.map { description in
            var copy = description
            if let end = description.endTime {
                copy.startTime = max(0, duration - end)
                copy.endTime = max(0, duration - description.startTime)
            } else {
                copy.startTime = max(0, duration - description.startTime)
            }
            return copy
        }
        return mirrored.sorted { $0.startTime < $1.startTime }
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

// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import Testing

@testable import SPFKMetadataBase

/// Where a marker lands after its file is trimmed.
///
/// A passthrough video export drops the chapter track outright, so these values are what gets
/// written back — not an adjustment applied to something the export preserved.
@Suite
final class AudioMarkerDescriptionTrimTests {
    private func marker(_ name: String, _ start: TimeInterval, _ end: TimeInterval? = nil) -> AudioMarkerDescription {
        AudioMarkerDescription(name: name, startTime: start, endTime: end)
    }

    @Test func markersShiftBackByTheInPoint() {
        let adjusted = AudioMarkerDescription.adjustedForTrim(
            [marker("a", 10), marker("b", 20)],
            inPoint: 5,
            outPoint: 0
        )

        #expect(adjusted.map(\.startTime) == [5, 15])
    }

    @Test func markersBeforeTheInPointAreDropped() {
        let adjusted = AudioMarkerDescription.adjustedForTrim(
            [marker("early", 2), marker("kept", 10)],
            inPoint: 5,
            outPoint: 0
        )

        #expect(adjusted.map(\.name) == ["kept"])
    }

    @Test func markersAtOrPastTheOutPointAreDropped() {
        let adjusted = AudioMarkerDescription.adjustedForTrim(
            [marker("kept", 10), marker("onOutPoint", 20), marker("past", 25)],
            inPoint: 0,
            outPoint: 20
        )

        #expect(adjusted.map(\.name) == ["kept"])
    }

    /// `0` means "keep to the end", the convention `TrimDescription` uses.
    @Test func anOutPointOfZeroKeepsEverythingAfterTheInPoint() {
        let adjusted = AudioMarkerDescription.adjustedForTrim(
            [marker("a", 10), marker("b", 900)],
            inPoint: 5,
            outPoint: 0
        )

        #expect(adjusted.count == 2)
    }

    @Test func regionEndsShiftWithTheirStart() {
        let adjusted = AudioMarkerDescription.adjustedForTrim(
            [marker("region", 10, 15)],
            inPoint: 5,
            outPoint: 0,
            newDuration: 100
        )

        #expect(adjusted.first?.startTime == 5)
        #expect(adjusted.first?.endTime == 10)
    }

    /// A region running past the out-point keeps its start and loses only the part that no longer
    /// exists. An end beyond the file's own duration is not a position anything can resolve.
    @Test func aRegionRunningPastTheEndIsClampedToTheNewDuration() {
        let adjusted = AudioMarkerDescription.adjustedForTrim(
            [marker("straddles", 10, 60)],
            inPoint: 5,
            outPoint: 45,
            newDuration: 40
        )

        #expect(adjusted.first?.startTime == 5)
        #expect(adjusted.first?.endTime == 40)
    }

    /// Without a duration the end is shifted but not bounded — the audio path's existing behavior.
    @Test func withoutADurationTheEndIsShiftedButNotClamped() {
        let adjusted = AudioMarkerDescription.adjustedForTrim(
            [marker("region", 10, 60)],
            inPoint: 5,
            outPoint: 0
        )

        #expect(adjusted.first?.endTime == 55)
    }

    @Test func aPointMarkerKeepsNoEnd() {
        let adjusted = AudioMarkerDescription.adjustedForTrim(
            [marker("point", 10)],
            inPoint: 5,
            outPoint: 0,
            newDuration: 40
        )

        #expect(adjusted.first?.endTime == nil)
    }

    /// The range clips a region rather than discarding it: the audio under a region spanning the
    /// in-point is still in the file, so the marker still describes something.
    @Test func aRegionSpanningTheInPointIsKeptAndStartsAtZero() {
        let adjusted = AudioMarkerDescription.adjustedForTrim(
            [marker("spans", 10, 60)],
            inPoint: 30,
            outPoint: 0,
            newDuration: 100
        )

        #expect(adjusted.first?.startTime == 0)
        #expect(adjusted.first?.endTime == 30)
    }

    /// A region wider than the trim on both sides becomes the whole trimmed file.
    @Test func aRegionSpanningTheWholeTrimCoversTheNewDuration() {
        let adjusted = AudioMarkerDescription.adjustedForTrim(
            [marker("everything", 2, 90)],
            inPoint: 10,
            outPoint: 40,
            newDuration: 30
        )

        #expect(adjusted.first?.startTime == 0)
        #expect(adjusted.first?.endTime == 30)
    }

    @Test func aRegionEndingBeforeTheInPointIsDropped() {
        let adjusted = AudioMarkerDescription.adjustedForTrim(
            [marker("early", 2, 4)],
            inPoint: 10,
            outPoint: 0
        )

        #expect(adjusted.isEmpty)
    }

    /// The kept range is half-open at both ends. A region finishing exactly where the range opens
    /// survives no more than a point marker sitting exactly where it closes.
    @Test func aRegionEndingExactlyOnTheInPointIsDropped() {
        let adjusted = AudioMarkerDescription.adjustedForTrim(
            [marker("touches", 2, 10)],
            inPoint: 10,
            outPoint: 0
        )

        #expect(adjusted.isEmpty)
    }

    @Test func aMarkerExactlyOnTheInPointIsKeptAtZero() {
        let adjusted = AudioMarkerDescription.adjustedForTrim(
            [marker("onInPoint", 10)],
            inPoint: 10,
            outPoint: 0
        )

        #expect(adjusted.map(\.startTime) == [0])
    }

    /// Nothing survives, and the caller gets an empty set rather than the originals — which is
    /// what lets it leave a file with no chapter track alone instead of writing pre-trim times.
    @Test func everyMarkerOutsideTheKeptRangeYieldsNothing() {
        let adjusted = AudioMarkerDescription.adjustedForTrim(
            [marker("before", 1), marker("alsoBefore", 2, 3), marker("after", 90)],
            inPoint: 10,
            outPoint: 20,
            newDuration: 10
        )

        #expect(adjusted.isEmpty)
    }
}

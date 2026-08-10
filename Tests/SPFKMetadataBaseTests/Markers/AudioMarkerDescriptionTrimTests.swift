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
}

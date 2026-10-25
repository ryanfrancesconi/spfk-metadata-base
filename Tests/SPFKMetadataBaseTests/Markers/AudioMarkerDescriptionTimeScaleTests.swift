// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKAudioBase
import SPFKBase
import Testing

@testable import SPFKMetadataBase

/// Where a marker lands after its file is trimmed and played back at another rate.
@Suite
final class AudioMarkerDescriptionTimeScaleTests {
    private func marker(_ name: String, _ start: TimeInterval, _ end: TimeInterval? = nil) -> AudioMarkerDescription {
        AudioMarkerDescription(name: name, startTime: start, endTime: end)
    }

    private func edit(_ trim: TrimDescription, rate: Double) -> AudioEditDescription {
        var edit = AudioEditDescription(trim: trim)
        edit.timePitch.rate = rate
        return edit
    }

    @Test func theTrimShiftsBeforeTheRateScales() {
        let markers = [marker("a", 10), marker("b", 20, 30)]

        let half = AudioMarkerDescription.adjusted(markers, for: edit(TrimDescription(inPoint: 4), rate: 0.5), newDuration: 100)
        #expect(half.map(\.startTime) == [12, 32])
        #expect(half.map(\.endTime) == [nil, 52])

        let double = AudioMarkerDescription.adjusted(markers, for: edit(TrimDescription(inPoint: 4), rate: 2), newDuration: 100)
        #expect(double.map(\.startTime) == [3, 8])
        #expect(double.map(\.endTime) == [nil, 13])
    }

    @Test func theWindowIsJudgedInSourceTime() {
        let markers = [marker("early", 2), marker("kept", 10), marker("onOut", 20), marker("straddles", 1, 6)]

        let adjusted = AudioMarkerDescription.adjusted(
            markers,
            for: edit(TrimDescription(inPoint: 5, outPoint: 20), rate: 2),
            newDuration: 7.5
        )

        #expect(adjusted.map(\.name) == ["kept", "straddles"])
        #expect(adjusted.map(\.startTime) == [2.5, 0])
        #expect(adjusted.map(\.endTime) == [nil, 0.5])
    }

    @Test func aRegionEndIsClampedToTheRenderedDuration() {
        let adjusted = AudioMarkerDescription.adjusted(
            [marker("region", 2, 12)],
            for: edit(TrimDescription(), rate: 0.5),
            newDuration: 20
        )

        #expect(adjusted.first?.startTime == 4)
        #expect(adjusted.first?.endTime == 20)
    }

    @Test func nothingInTheWindowIsEmpty() {
        let adjusted = AudioMarkerDescription.adjusted(
            [marker("a", 1), marker("b", 30)],
            for: edit(TrimDescription(inPoint: 5, outPoint: 20), rate: 1.5),
            newDuration: 10
        )

        #expect(adjusted.isEmpty)
    }

    /// The model resolves a non-finite rate to 1.
    @Test(arguments: [1.0, .nan, .infinity])
    func anUnusableOrUnitScaleIsTheTrimAlone(timeScale: Double) {
        let markers = [marker("a", 10), marker("b", 20, 40), marker("c", 2)]
        let trim = TrimDescription(inPoint: 5, outPoint: 30)

        let adjusted = AudioMarkerDescription.adjusted(markers, for: edit(trim, rate: timeScale), newDuration: 25)
        let trimmed = AudioMarkerDescription.adjustedForTrim(markers, inPoint: 5, outPoint: 30, newDuration: 25)

        #expect(adjusted == trimmed)
    }
}

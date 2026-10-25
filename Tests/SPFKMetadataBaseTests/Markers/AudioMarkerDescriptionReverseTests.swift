// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKAudioBase
import SPFKBase
import SPFKTesting
import Testing

@testable import SPFKMetadataBase

/// Where a marker lands after a render of a reversed edit.
@Suite(.tags(.reverse))
final class AudioMarkerDescriptionReverseTests {
    private func marker(_ name: String, _ start: TimeInterval, _ end: TimeInterval? = nil) -> AudioMarkerDescription {
        AudioMarkerDescription(name: name, startTime: start, endTime: end)
    }

    private func reversed(_ trim: TrimDescription = TrimDescription(), rate: Double = 1) -> AudioEditDescription {
        var edit = AudioEditDescription(trim: trim, isReversed: true)
        edit.timePitch.rate = rate
        return edit
    }

    @Test func pointsMirrorAndRegionsSwapTheirEnds() {
        let adjusted = AudioMarkerDescription.adjusted(
            [marker("point", 2), marker("region", 3, 5)],
            for: reversed(),
            newDuration: 10
        )

        #expect(adjusted.map(\.name) == ["region", "point"])
        #expect(adjusted.map(\.startTime) == [5, 8])
        #expect(adjusted.map(\.endTime) == [7, nil])
    }

    @Test func aRegionCrossingTheOutPointIsClampedThenMirrored() {
        let adjusted = AudioMarkerDescription.adjusted(
            [marker("crosses", 6, 12)],
            for: reversed(TrimDescription(inPoint: 2, outPoint: 10)),
            newDuration: 8
        )

        #expect(adjusted.first?.startTime == 0)
        #expect(adjusted.first?.endTime == 4)
    }

    @Test func mirrorsAfterTheTrimAndTheRate() {
        // Trim [4, 24], rate 2: 10 → 3, region 14–18 → 5–7, in a 10 s render.
        let adjusted = AudioMarkerDescription.adjusted(
            [marker("a", 10), marker("b", 14, 18), marker("outside", 30)],
            for: reversed(TrimDescription(inPoint: 4, outPoint: 24), rate: 2),
            newDuration: 10
        )

        #expect(adjusted.map(\.name) == ["b", "a"])
        #expect(adjusted.map(\.startTime) == [3, 7])
        #expect(adjusted.map(\.endTime) == [5, nil])
    }

    @Test func aPointOnTheInPointLandsAtTheEnd() {
        let adjusted = AudioMarkerDescription.adjusted(
            [marker("onIn", 3)],
            for: reversed(TrimDescription(inPoint: 3, outPoint: 9)),
            newDuration: 6
        )

        #expect(adjusted.map(\.startTime) == [6])
    }

    @Test func nothingInTheWindowIsEmpty() {
        let adjusted = AudioMarkerDescription.adjusted(
            [marker("a", 1), marker("b", 30)],
            for: reversed(TrimDescription(inPoint: 5, outPoint: 20)),
            newDuration: 15
        )

        #expect(adjusted.isEmpty)
    }

    @Test func mirroredMarkersAreInAscendingOrder() {
        let mirrored = AudioMarkerDescription.mirrored([marker("a", 1), marker("b", 2), marker("c", 3, 4)], duration: 10)
        #expect(mirrored.map(\.name) == ["c", "b", "a"])
    }

    @Test func mirroredTwiceIsIdentity() {
        let markers = [marker("point", 1.5), marker("region", 2, 4.25)]
        #expect(AudioMarkerDescription.mirrored(AudioMarkerDescription.mirrored(markers, duration: 10), duration: 10) == markers)
    }
}

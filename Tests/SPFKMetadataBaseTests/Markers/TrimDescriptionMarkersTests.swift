// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi

import Foundation
import SPFKAudioBase
import SPFKBase
import Testing

@testable import SPFKMetadataBase

struct TrimDescriptionMarkersTests {
    // MARK: - asSegmentMarkers naming

    @Test("asSegmentMarkers names segments In 01, In 02, … in order")
    func namingConvention() {
        let segments: [TrimDescription] = [
            TrimDescription(inPoint: 0.0, outPoint: 1.0),
            TrimDescription(inPoint: 2.0, outPoint: 3.0),
            TrimDescription(inPoint: 4.0, outPoint: 5.0),
        ]

        let markers = segments.asSegmentMarkers()

        #expect(markers[0].name == "In 01")
        #expect(markers[1].name == "In 02")
        #expect(markers[2].name == "In 03")
    }

    @Test("asSegmentMarkers pads single-digit index to two digits")
    func namePaddingBeyondNine() {
        let segments = (1 ... 10).map { i in
            TrimDescription(inPoint: Double(i - 1), outPoint: Double(i))
        }

        let markers = segments.asSegmentMarkers()

        #expect(markers[8].name == "In 09")
        #expect(markers[9].name == "In 10")
    }

    // MARK: - asSegmentMarkers times

    @Test("asSegmentMarkers maps inPoint → startTime and outPoint → endTime")
    func timesMapping() {
        let segments: [TrimDescription] = [
            TrimDescription(inPoint: 0.5, outPoint: 1.5),
            TrimDescription(inPoint: 2.0, outPoint: 3.0),
        ]

        let markers = segments.asSegmentMarkers()

        #expect(markers[0].startTime == 0.5)
        #expect(markers[0].endTime == 1.5)
        #expect(markers[1].startTime == 2.0)
        #expect(markers[1].endTime == 3.0)
    }

    // MARK: - asSegmentMarkers type

    @Test("asSegmentMarkers produces .region markers")
    func markerType() {
        let segments: [TrimDescription] = [TrimDescription(inPoint: 0.0, outPoint: 1.0)]
        let markers = segments.asSegmentMarkers()

        #expect(markers[0].markerType == .region)
    }

    // MARK: - asSegmentMarkers color

    @Test("asSegmentMarkers assigns a non-nil hexColor to every marker")
    func hexColorAssigned() {
        let segments: [TrimDescription] = [
            TrimDescription(inPoint: 0.0, outPoint: 1.0),
            TrimDescription(inPoint: 2.0, outPoint: 3.0),
        ]

        let markers = segments.asSegmentMarkers()

        #expect(markers[0].hexColor != nil)
        #expect(markers[1].hexColor != nil)
        #expect(markers[0].hexColor == markers[1].hexColor) // consistent default
    }

    // MARK: - asSegmentMarkers edge cases

    @Test("empty segment array produces empty marker array")
    func emptyInput() {
        let markers = [TrimDescription]().asSegmentMarkers()
        #expect(markers.isEmpty)
    }

    @Test("single segment produces exactly one marker named In 01")
    func singleSegment() {
        let markers = [TrimDescription(inPoint: 0.1, outPoint: 0.9)].asSegmentMarkers()

        #expect(markers.count == 1)
        #expect(markers[0].name == "In 01")
        #expect(markers[0].startTime == 0.1)
        #expect(markers[0].endTime == 0.9)
    }
}

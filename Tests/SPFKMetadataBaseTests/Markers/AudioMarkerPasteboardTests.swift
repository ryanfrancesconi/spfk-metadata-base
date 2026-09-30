// Copyright Ryan Francesconi. All Rights Reserved.

#if os(macOS)

    import AppKit
    import Foundation
    import SPFKBase
    import Testing

    @testable import SPFKMetadataBase

    @Suite(.serialized)
    struct AudioMarkerPasteboardTests {
        /// A uniquely named board, never `.general`, which every process and the user's own
        /// clipboard contend for.
        private let pasteboard = NSPasteboard(name: .init("AudioMarkerPasteboardTests"))

        @Test func markersRoundTripThroughThePasteboard() throws {
            let markers = [
                AudioMarkerDescription(name: "Cue", startTime: 1.5, hexColor: HexColor(string: "FF0000")),
                AudioMarkerDescription(name: "Verse", startTime: 3, endTime: 7.25, hexColor: HexColor(string: "00FF00"), markerType: .region),
            ]

            try AudioMarkerDescriptionCollection(markerDescriptions: markers).toPasteboard(pasteboard)
            let decoded: AudioMarkerDescriptionCollection = try AudioMarkerDescriptionCollection.fromPasteboard(pasteboard)

            #expect(decoded.markerDescriptions.map(\.startTime) == [1.5, 3])
            #expect(decoded.markerDescriptions.map(\.endTime) == [nil, 7.25])
            #expect(decoded.markerDescriptions.map(\.name) == ["Cue", "Verse"])
            #expect(decoded.markerDescriptions.map(\.hexColor) == markers.map(\.hexColor))
            #expect(decoded.markerDescriptions.map(\.markerType) == [.cue, .region])
        }

        /// Another payload's JSON must not decode as an empty marker set.
        @Test func anotherPayloadIsNotReadAsMarkers() throws {
            var tags = TagData()
            tags.tags[.title] = "Title"
            try tags.toPasteboard(pasteboard)

            #expect(throws: (any Error).self) {
                let _: AudioMarkerDescriptionCollection = try AudioMarkerDescriptionCollection.fromPasteboard(pasteboard)
            }
        }
    }

#endif

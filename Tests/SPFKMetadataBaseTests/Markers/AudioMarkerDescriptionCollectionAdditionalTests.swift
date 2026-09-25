import Foundation
import SPFKBase
import Testing

@testable import SPFKMetadataBase

struct AudioMarkerDescriptionCollectionAdditionalTests {
    // MARK: - remove

    @Test func removeMarkerByID() throws {
        var collection = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "M1", startTime: 0),
            AudioMarkerDescription(name: "M2", startTime: 1),
            AudioMarkerDescription(name: "M3", startTime: 2),
        ])

        #expect(collection.count == 3)
        try collection.remove(markerID: 1)
        #expect(collection.count == 2)
        #expect(!collection.allIDs.contains(1))
    }

    @Test func removeMarkerByIDNotFound() {
        var collection = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "M1", startTime: 0)
        ])

        #expect(throws: Error.self) {
            try collection.remove(markerID: 999)
        }
    }

    // MARK: - update

    @Test func updateMarker() throws {
        var collection = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "M1", startTime: 0),
            AudioMarkerDescription(name: "M2", startTime: 1),
        ])

        var updated = AudioMarkerDescription(name: "M2 Updated", startTime: 1.5)
        updated.markerID = 1

        try collection.update(markerID: 1, markerDescription: updated)

        let marker = collection.markerDescriptions.first(where: { $0.markerID == 1 })
        #expect(marker?.name == "M2 Updated")
        #expect(marker?.startTime == 1.5)
    }

    @Test func updateMarkerWithNilDescriptionID() throws {
        var collection = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "M1", startTime: 0)
        ])

        // markerID parameter is used to locate the marker, so nil on the description is fine
        let noID = AudioMarkerDescription(name: "Updated", startTime: 0.5)
        try collection.update(markerID: 0, markerDescription: noID)

        let marker = collection.markerDescriptions.first(where: { $0.markerID == nil })
        #expect(marker?.name == "Updated")
    }

    @Test func updateMarkerNotFound() {
        var collection = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "M1", startTime: 0)
        ])

        var marker = AudioMarkerDescription(name: "X", startTime: 0)
        marker.markerID = 999

        #expect(throws: Error.self) {
            try collection.update(markerID: 999, markerDescription: marker)
        }
    }

    // MARK: - insertAndIncrementID

    @Test func insertAndIncrementID() throws {
        var collection = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "M1", startTime: 0)
        ])

        let marker = AudioMarkerDescription(name: nil, startTime: 5)
        let inserted = try collection.insertAndIncrementID(markerDescription: marker)

        #expect(inserted.markerID == 1)
        #expect(inserted.name == "Marker 1") // auto-named
        #expect(collection.count == 2)
    }

    // MARK: - update(markerDescriptions:) preserves IDs

    @Test func updatePreservesExistingIDs() {
        var collection = AudioMarkerDescriptionCollection()
        collection.update(markerDescriptions: [
            AudioMarkerDescription(name: "C", startTime: 3, markerID: 99),
            AudioMarkerDescription(name: "A", startTime: 1, markerID: 50),
            AudioMarkerDescription(name: "B", startTime: 2, markerID: 75),
        ])

        // sorted by startTime
        #expect(collection.markerDescriptions[0].startTime == 1)
        #expect(collection.markerDescriptions[1].startTime == 2)
        #expect(collection.markerDescriptions[2].startTime == 3)

        // existing IDs preserved — not reassigned sequentially
        #expect(collection.markerDescriptions[0].markerID == 50)
        #expect(collection.markerDescriptions[1].markerID == 75)
        #expect(collection.markerDescriptions[2].markerID == 99)
    }

    @Test func updateAutoNamesNilMarkers() {
        var collection = AudioMarkerDescriptionCollection()
        collection.update(markerDescriptions: [
            AudioMarkerDescription(name: nil, startTime: 0),
            AudioMarkerDescription(name: "Named", startTime: 1),
            AudioMarkerDescription(name: nil, startTime: 2),
        ])

        #expect(collection.markerDescriptions[0].name == "Marker 0")
        #expect(collection.markerDescriptions[1].name == "Named")
        #expect(collection.markerDescriptions[2].name == "Marker 2")
    }

    // MARK: - Codable

    @Test func codableRoundTrip() throws {
        let collection = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "M1", startTime: 0),
            AudioMarkerDescription(name: "M2", startTime: 1),
            AudioMarkerDescription(name: "M3", startTime: 2),
        ])

        let data = try JSONEncoder().encode(collection)
        let decoded = try JSONDecoder().decode(AudioMarkerDescriptionCollection.self, from: data)

        #expect(decoded.count == 3)
        #expect(decoded.markerDescriptions[0].name == "M1")
        #expect(decoded.markerDescriptions[1].name == "M2")
        #expect(decoded.markerDescriptions[2].name == "M3")
    }

    @Test func codableEmpty() throws {
        let collection = AudioMarkerDescriptionCollection()
        let data = try JSONEncoder().encode(collection)
        let decoded = try JSONDecoder().decode(AudioMarkerDescriptionCollection.self, from: data)

        #expect(decoded.count == 0)
    }

    // MARK: - highestID / allIDs

    @Test func highestIDEmpty() {
        let collection = AudioMarkerDescriptionCollection()
        #expect(collection.highestID == -1)
    }

    @Test func allIDsEmpty() {
        let collection = AudioMarkerDescriptionCollection()
        #expect(collection.allIDs.isEmpty)
    }

    // MARK: - removeSegmentMarkers

    @Test("removeSegmentMarkers removes all In NN-named markers and leaves others untouched")
    func removeSegmentMarkersLeavesOthers() {
        var collection = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "In 01", startTime: 1.0, markerType: .region),
            AudioMarkerDescription(name: "In 02", startTime: 2.0, markerType: .region),
            AudioMarkerDescription(name: "Cue Point", startTime: 3.0),
            AudioMarkerDescription(name: "Chapter 1", startTime: 4.0, markerType: .region),
        ])

        collection.removeSegmentMarkers()

        let names = collection.markerDescriptions.compactMap(\.name)
        #expect(collection.count == 2)
        #expect(!names.contains("In 01"))
        #expect(!names.contains("In 02"))
        #expect(names.contains("Cue Point"))
        #expect(names.contains("Chapter 1"))
    }

    @Test("removeSegmentMarkers on empty collection is a no-op")
    func removeSegmentMarkersEmpty() {
        var collection = AudioMarkerDescriptionCollection()
        collection.removeSegmentMarkers()
        #expect(collection.count == 0)
    }

    @Test("removeSegmentMarkers removes all markers when all are segment markers")
    func removeSegmentMarkersAll() {
        var collection = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "In 01", startTime: 0.5, markerType: .region),
            AudioMarkerDescription(name: "In 02", startTime: 1.5, markerType: .region),
        ])

        collection.removeSegmentMarkers()
        #expect(collection.count == 0)
    }

    @Test("removeSegmentMarkers does not match names that only resemble the pattern")
    func removeSegmentMarkersPatternEdgeCases() {
        var collection = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "In",     startTime: 0.1),  // no trailing number
            AudioMarkerDescription(name: "In 01",  startTime: 0.2, markerType: .region), // matches
            AudioMarkerDescription(name: "In01",   startTime: 0.3),  // no space
            AudioMarkerDescription(name: "In 01X", startTime: 0.4),  // trailing non-digit
            AudioMarkerDescription(name: "In 1",   startTime: 0.5, markerType: .region), // matches
        ])

        collection.removeSegmentMarkers()

        let names = collection.markerDescriptions.compactMap(\.name)
        #expect(collection.count == 3)
        #expect(!names.contains("In 01"))
        #expect(!names.contains("In 1"))
        #expect(names.contains("In"))
        #expect(names.contains("In01"))
        #expect(names.contains("In 01X"))
    }

    // MARK: - insert deduplication

    @Test func insertIgnoresDuplicateStartTimes() throws {
        var collection = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "Existing", startTime: 1.0)
        ])

        try collection.insert(markerDescriptions: [
            AudioMarkerDescription(name: "Duplicate", startTime: 1.0),
            AudioMarkerDescription(name: "New", startTime: 2.0),
        ])

        #expect(collection.count == 2)
        // "Duplicate" at startTime 1.0 should have been ignored
        let names = collection.markerDescriptions.compactMap(\.name)
        #expect(!names.contains("Duplicate"))
        #expect(names.contains("New"))
    }

    // MARK: - mergeColors

    @Test func mergeColorsById() throws {
        let red = try #require(HexColor(string: "FF0000FF"))
        let previous = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "A", startTime: 0, markerID: 0, hexColor: red),
        ])
        var fresh = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "A", startTime: 0, markerID: 0),
        ])
        fresh.mergeColors(from: previous)
        #expect(fresh.markerDescriptions[0].hexColor?.stringValue == "FF0000FF")
    }

    @Test func mergeColorsFallbackByNameAndTime() throws {
        let blue = try #require(HexColor(string: "0000FFFF"))
        // previous has markerID 5; fresh has a different ID (99) but same name+startTime
        let previous = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "B", startTime: 2.5, markerID: 5, hexColor: blue),
        ])
        var fresh = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "B", startTime: 2.5, markerID: 99),
        ])
        fresh.mergeColors(from: previous)
        #expect(fresh.markerDescriptions[0].hexColor?.stringValue == "0000FFFF")
    }

    @Test func mergeColorsPreservesExistingColor() throws {
        let red = try #require(HexColor(string: "FF0000FF"))
        let green = try #require(HexColor(string: "00FF00FF"))
        let previous = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "A", startTime: 0, markerID: 0, hexColor: red),
        ])
        var fresh = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "A", startTime: 0, markerID: 0, hexColor: green),
        ])
        fresh.mergeColors(from: previous)
        // existing color (green) must not be overwritten by previous (red)
        #expect(fresh.markerDescriptions[0].hexColor?.stringValue == "00FF00FF")
    }

    // MARK: - insert

    @Test func insertAssignsSequentialIDs() throws {
        var collection = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "Marker 1", startTime: 0),
            AudioMarkerDescription(name: "Marker 2", startTime: 1),
            AudioMarkerDescription(name: "Marker 3", startTime: 2),
        ])

        try collection.insert(markerDescriptions: [
            AudioMarkerDescription(name: "Marker 4", startTime: 3)
        ])

        // startTime exists, so this marker should be ignored
        try collection.insert(markerDescriptions: [
            AudioMarkerDescription(name: "Marker 5", startTime: 3)
        ])

        #expect(collection.count == 4)
        #expect(collection.allIDs == [0, 1, 2, 3])
        #expect(collection.highestID == 3)
    }
}

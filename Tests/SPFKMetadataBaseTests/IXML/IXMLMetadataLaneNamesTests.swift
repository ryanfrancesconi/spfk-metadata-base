// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import Testing

@testable import SPFKMetadataBase

@Suite
final class IXMLMetadataLaneNamesTests {
    private typealias Track = IXMLMetadata.Track

    private func metadata(_ tracks: [Track]) -> IXMLMetadata {
        var ixml = IXMLMetadata()
        ixml.tracks = tracks
        return ixml
    }

    @Test func unnamedTracksKeepTheirLanes() {
        let ixml = metadata([
            Track(interleaveIndex: "1"),
            Track(interleaveIndex: "2", name: "Lav"),
        ])

        #expect(ixml.laneNames(count: 2) == ["", "Lav"])
    }

    @Test func lanesFollowInterleaveIndexNotDocumentOrder() {
        let ixml = metadata([
            Track(interleaveIndex: "2", name: "Lav"),
            Track(interleaveIndex: "1", name: "Boom"),
        ])

        #expect(ixml.laneNames(count: 2) == ["Boom", "Lav"])
    }

    @Test func lanesFallBackToPositionWithoutInterleaveIndexes() {
        let ixml = metadata([
            Track(name: "Boom"),
            Track(interleaveIndex: "x", name: "Lav"),
        ])

        #expect(ixml.laneNames(count: 3) == ["Boom", "Lav", ""])
    }

    @Test func noTrackListReadsAsUnnamedLanes() {
        #expect(IXMLMetadata().laneNames(count: 2) == ["", ""])
    }

    @Test func writingCreatesOneTrackPerLane() throws {
        var ixml = IXMLMetadata()
        ixml.setLaneNames(["Boom", "", "Lav"])

        #expect(ixml.tracks == [
            Track(channelIndex: "1", interleaveIndex: "1", name: "Boom"),
            Track(channelIndex: "2", interleaveIndex: "2"),
            Track(channelIndex: "3", interleaveIndex: "3", name: "Lav"),
        ])

        let parsed = try IXMLMetadata(xml: ixml.xml)
        let trackList = try #require(parsed.document.root[.trackList])
        #expect(trackList[.trackCount]?.value == "3")
        #expect(parsed.laneNames(count: 3) == ["Boom", "", "Lav"])
    }

    @Test func writingNoNamesCreatesNoTrackList() {
        var ixml = IXMLMetadata()
        ixml.setLaneNames(["", ""])

        #expect(ixml.tracks == nil)
    }

    @Test func anEmptyNameRemovesOnlyTheName() throws {
        var ixml = metadata([
            Track(channelIndex: "1", interleaveIndex: "1", name: "Boom", function: "INPUT"),
            Track(channelIndex: "2", interleaveIndex: "2", name: "Lav"),
        ])
        ixml.setLaneNames(["", "Lav"])

        #expect(ixml.tracks == [
            Track(channelIndex: "1", interleaveIndex: "1", function: "INPUT"),
            Track(channelIndex: "2", interleaveIndex: "2", name: "Lav"),
        ])

        let parsed = try IXMLMetadata(xml: ixml.xml)
        #expect(parsed.tracks?.count == 2)
        #expect(parsed.laneNames(count: 2) == ["", "Lav"])
    }

    @Test func writingFollowsInterleaveIndex() {
        var ixml = metadata([
            Track(interleaveIndex: "2", name: "Lav"),
            Track(interleaveIndex: "1", name: "Boom"),
        ])
        ixml.setLaneNames(["Mic A", "Mic B"])

        #expect(ixml.tracks?.map(\.name) == ["Mic B", "Mic A"])
    }

    @Test func tracksBeyondTheLaneCountSurviveAWrite() {
        let extra = Track(channelIndex: "8", interleaveIndex: "8", name: "Mix L", function: "MIX")
        var ixml = metadata([
            Track(channelIndex: "1", interleaveIndex: "1", name: "Boom"),
            Track(channelIndex: "2", interleaveIndex: "2", name: "Lav"),
            extra,
        ])
        ixml.setLaneNames(["Boom 2", "Lav 2"])

        #expect(ixml.tracks?.count == 3)
        #expect(ixml.tracks?.last == extra)
        #expect(ixml.laneNames(count: 2) == ["Boom 2", "Lav 2"])
    }

    @Test func appendingToAPositionalListKeepsItPositional() throws {
        var ixml = metadata([Track(name: "Boom")])
        ixml.setLaneNames(["Boom", "Lav"])

        let parsed = try IXMLMetadata(xml: ixml.xml)
        #expect(parsed.laneNames(count: 2) == ["Boom", "Lav"])
    }

    @Test func aRoundTripThroughXMLReturnsWhatWasWritten() throws {
        var ixml = metadata([
            Track(interleaveIndex: "2", name: "Lav"),
            Track(interleaveIndex: "1"),
        ])
        let names = ["Boom", "Lav", "Plant"]
        ixml.setLaneNames(names)

        let parsed = try IXMLMetadata(xml: ixml.xml)
        #expect(parsed.laneNames(count: 3) == names)
    }

    @Test(arguments: [
        (["M", "S"], true),
        (["Mid", "Side"], true),
        (["m ", " S"], true),
        (["Boom", "Lav"], false),
        (["S", "M"], false),
    ])
    func midSideNameRuleMatchesDetection(names: [String], expected: Bool) {
        let ixml = metadata(names.map { Track(name: $0) })

        #expect(IXMLMetadata.namesDescribeMidSide(names) == expected)
        #expect(ixml.describesMidSide == expected)
    }
}

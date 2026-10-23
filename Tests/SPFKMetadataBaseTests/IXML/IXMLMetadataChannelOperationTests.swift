// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKAudioBase
import SPFKBase
import Testing

@testable import SPFKMetadataBase

@Suite
final class IXMLMetadataChannelOperationTests {
    private typealias Track = IXMLMetadata.Track

    /// `ixml.wav`'s TRACK_LIST, with its names replaceable.
    private func metadata(names: (String, String) = ("Mid", "Side"), functions: (String?, String?) = ("M-MID_SIDE", "S-MID_SIDE")) throws -> IXMLMetadata {
        func element(_ name: String, _ function: String?) -> String {
            "<NAME>\(name)</NAME>" + (function.map { "<FUNCTION>\($0)</FUNCTION>" } ?? "")
        }
        return try IXMLMetadata(xml: """
        <?xml version="1.0" encoding="UTF-8"?>
        <BWFXML>
            <TRACK_LIST>
                <TRACK_COUNT>2</TRACK_COUNT>
                <TRACK><CHANNEL_INDEX>1</CHANNEL_INDEX><INTERLEAVE_INDEX>1</INTERLEAVE_INDEX>\(element(names.0, functions.0))</TRACK>
                <TRACK><CHANNEL_INDEX>2</CHANNEL_INDEX><INTERLEAVE_INDEX>2</INTERLEAVE_INDEX>\(element(names.1, functions.1))</TRACK>
            </TRACK_LIST>
        </BWFXML>
        """)
    }

    private func applied(_ operation: ChannelOperation, to ixml: IXMLMetadata) throws -> [Track] {
        var ixml = ixml
        ixml.applyChannelOperation(operation)
        // Through the writer and back, so the TRACK elements themselves are checked.
        return try #require(IXMLMetadata(xml: ixml.xml).tracks)
    }

    // MARK: - Detection

    @Test func detectsMidSideFromFunctionsOrNames() throws {
        #expect(try metadata().describesMidSide)
        #expect(try metadata(names: ("Boom", "Lav")).describesMidSide)
        #expect(try metadata(names: (" m ", "S"), functions: (nil, nil)).describesMidSide)
        #expect(try metadata(names: ("MID", "side"), functions: (nil, nil)).describesMidSide)
    }

    @Test func rejectsOtherTrackLists() throws {
        #expect(try !metadata(names: ("L", "R"), functions: (nil, nil)).describesMidSide)
        #expect(try !metadata(names: ("Side", "Mid"), functions: (nil, nil)).describesMidSide)

        var three = try metadata()
        three.tracks?.append(Track(channelIndex: "3", interleaveIndex: "3", name: "Side"))
        #expect(!three.describesMidSide)

        #expect(!IXMLMetadata().describesMidSide)
    }

    // MARK: - Transform

    @Test func swapExchangesTracksAndKeepsPositions() throws {
        let tracks = try applied(.swap, to: metadata(names: ("Boom", "Lav"), functions: ("INPUT", nil)))
        #expect(tracks == [
            Track(channelIndex: "2", interleaveIndex: "1", name: "Lav"),
            Track(channelIndex: "1", interleaveIndex: "2", name: "Boom", function: "INPUT"),
        ])
    }

    @Test func monoAverageIsOneUnnamedSourceTrack() throws {
        let ixml = try metadata(names: ("Boom", "Lav"), functions: (nil, nil))
        #expect(try applied(.mono(.average), to: ixml) == [Track(interleaveIndex: "1", name: "Mono")])
    }

    @Test func keepingOneChannelKeepsItsTrack() throws {
        #expect(try applied(.mono(.left), to: metadata()) == [
            Track(channelIndex: "1", interleaveIndex: "1", name: "Mid", function: "M-MID_SIDE"),
        ])
        #expect(try applied(.mono(.right), to: metadata()) == [
            Track(channelIndex: "2", interleaveIndex: "1", name: "Side", function: "S-MID_SIDE"),
        ])
    }

    @Test func decodeNamesLeftAndRight() throws {
        let tracks = try applied(.midSideDecode(width: 1), to: metadata())
        #expect(tracks == [
            Track(channelIndex: "1", interleaveIndex: "1", name: "L"),
            Track(channelIndex: "2", interleaveIndex: "2", name: "R"),
        ])
    }

    @Test func encodeNamesMidAndSideAndDetects() throws {
        var ixml = try metadata(names: ("L", "R"), functions: (nil, nil))
        ixml.applyChannelOperation(.midSideEncode)
        #expect(ixml.tracks == [
            Track(channelIndex: "1", interleaveIndex: "1", name: "M", function: "M-MID_SIDE"),
            Track(channelIndex: "2", interleaveIndex: "2", name: "S", function: "S-MID_SIDE"),
        ])
        #expect(ixml.describesMidSide)
    }

    @Test func trackCountFollowsTheTransform() throws {
        var ixml = try metadata()
        ixml.applyChannelOperation(.mono(.left))
        #expect(ixml.xml.contains("<TRACK_COUNT>1</TRACK_COUNT>"))
    }

    @Test func noTrackListStaysAbsent() throws {
        var ixml = try IXMLMetadata(xml: "<BWFXML><PROJECT>P</PROJECT></BWFXML>")
        ixml.applyChannelOperation(.mono(.average))
        #expect(ixml.tracks == nil)
    }
}

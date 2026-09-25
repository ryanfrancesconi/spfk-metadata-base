// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import Testing

@testable import SPFKMetadataBase

/// The labels come from `AudioTerminology`; these pin how a file's properties compose them.
@Suite
struct SampleRateDescriptionTests {
    @Test func aCompressedFileListsRateBitRateAndChannels() {
        let properties = AudioFormatProperties(channelCount: 2, sampleRate: 44100, bitRate: 320, duration: 1)
        #expect(properties.bitRateDescription == "320 kbps")
        #expect(properties.channelsDescription == "Stereo")
        #expect(properties.formatDescription.hasSuffix(", 320 kbps, Stereo"))
    }

    @Test func aPCMFileListsRateDepthAndChannels() {
        let properties = AudioFormatProperties(channelCount: 6, sampleRate: 48000, bitsPerChannel: 24, duration: 1)
        #expect(properties.bitRateDescription == "")
        #expect(properties.channelsDescription == "6 Channels")
        #expect(properties.formatDescription.hasSuffix(", 24 bit, 6 Channels"))
    }

    @Test func noChannelsLeavesTheChannelLabelOut() {
        let properties = AudioFormatProperties(channelCount: 0, sampleRate: 48000, duration: 1)
        #expect(properties.channelsDescription == "")
        #expect(!properties.formatDescription.hasSuffix(", "))
    }
}

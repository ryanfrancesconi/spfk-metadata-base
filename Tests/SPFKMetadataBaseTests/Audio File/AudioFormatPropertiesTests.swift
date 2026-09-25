// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import Testing

@testable import SPFKMetadataBase

struct AudioFormatPropertiesTests {
    // MARK: - Channel Description

    @Test func monoChannelDescription() {
        let props = AudioFormatProperties(channelCount: 1, sampleRate: 44100, duration: 1.0)
        #expect(props.channelsDescription == "Mono")
    }

    @Test func stereoChannelDescription() {
        let props = AudioFormatProperties(channelCount: 2, sampleRate: 44100, duration: 1.0)
        #expect(props.channelsDescription == "Stereo")
    }

    @Test func multiChannelDescription() {
        let props = AudioFormatProperties(channelCount: 6, sampleRate: 48000, duration: 1.0)
        #expect(props.channelsDescription == "6 Channels")
    }

    @Test func zeroChannelDescription() {
        let props = AudioFormatProperties(channelCount: 0, sampleRate: 44100, duration: 1.0)
        #expect(props.channelsDescription == "")
    }

    // MARK: - Bit Rate Description

    @Test func bitRateDescription() {
        let props = AudioFormatProperties(channelCount: 2, sampleRate: 44100, bitRate: 320, duration: 1.0)
        #expect(props.bitRateDescription == "320 kbps")
    }

    @Test func noBitRateDescription() {
        let props = AudioFormatProperties(channelCount: 2, sampleRate: 44100, duration: 1.0)
        #expect(props.bitRateDescription == "")
    }

    @Test func zeroBitRateDescription() {
        let props = AudioFormatProperties(channelCount: 2, sampleRate: 44100, bitRate: 0, duration: 1.0)
        #expect(props.bitRateDescription == "")
    }

    // MARK: - Format Description

    @Test func formatDescriptionStereo44kHz24Bit() {
        let props = AudioFormatProperties(
            channelCount: 2,
            sampleRate: 44100,
            bitsPerChannel: 24,
            duration: 1.0
        )
        #expect(props.formatDescription == "44.1 kHz, 24 bit, Stereo")
    }

    @Test func formatDescriptionStereo48kHz() {
        let props = AudioFormatProperties(
            channelCount: 2,
            sampleRate: 48000,
            bitsPerChannel: 16,
            duration: 1.0
        )
        // 48000/1000 = 48.0, truncates to "48"
        #expect(props.formatDescription == "48 kHz, 16 bit, Stereo")
    }

    @Test func formatDescriptionWithBitRate() {
        let props = AudioFormatProperties(
            channelCount: 2,
            sampleRate: 44100,
            bitRate: 320,
            duration: 1.0
        )
        #expect(props.formatDescription == "44.1 kHz, 320 kbps, Stereo")
    }

    @Test func formatDescriptionMono96kHz() {
        let props = AudioFormatProperties(
            channelCount: 1,
            sampleRate: 96000,
            bitsPerChannel: 24,
            duration: 1.0
        )
        #expect(props.formatDescription == "96 kHz, 24 bit, Mono")
    }

    @Test func formatDescriptionNoChannels() {
        let props = AudioFormatProperties(
            channelCount: 0,
            sampleRate: 44100,
            bitsPerChannel: 16,
            duration: 1.0
        )
        // No channels means no channel suffix
        #expect(props.formatDescription == "44.1 kHz, 16 bit")
    }

    // MARK: - Duration Description

    @Test func durationDescriptionNonZero() {
        let props = AudioFormatProperties(channelCount: 2, sampleRate: 44100, duration: 222.15)
        #expect(props.durationDescription.isEmpty == false)
    }

    @Test func durationDescriptionZero() {
        let props = AudioFormatProperties(channelCount: 2, sampleRate: 44100, duration: 0)
        #expect(props.durationDescription.isEmpty == false) // Should still produce a string
    }

    // MARK: - update(bitRate:)

    @Test func updateBitRateRefreshesDescriptions() {
        var props = AudioFormatProperties(channelCount: 2, sampleRate: 44100, duration: 1.0)
        #expect(props.bitRateDescription == "")

        props.update(bitRate: 256)

        #expect(props.bitRateDescription == "256 kbps")
        #expect(props.formatDescription.contains("256 kbps"))
    }

    // MARK: - Codable

    @Test func codableRoundTrip() throws {
        let original = AudioFormatProperties(
            channelCount: 2,
            sampleRate: 44100,
            bitsPerChannel: 24,
            bitRate: 320,
            duration: 123.456
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AudioFormatProperties.self, from: data)

        #expect(decoded.channelCount == original.channelCount)
        #expect(decoded.sampleRate == original.sampleRate)
        #expect(decoded.bitsPerChannel == original.bitsPerChannel)
        #expect(decoded.bitRate == original.bitRate)
        #expect(decoded.duration == original.duration)
    }

    @Test func codableRegeneratesDescriptions() throws {
        let original = AudioFormatProperties(
            channelCount: 2,
            sampleRate: 48000,
            bitsPerChannel: 16,
            duration: 10.0
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AudioFormatProperties.self, from: data)

        // Descriptions are not encoded — they are regenerated on decode via initialize()
        #expect(decoded.channelsDescription == "Stereo")
        #expect(decoded.formatDescription == original.formatDescription)
        #expect(decoded.durationDescription == original.durationDescription)
    }

    @Test func codableNilOptionals() throws {
        let original = AudioFormatProperties(channelCount: 1, sampleRate: 22050, duration: 5.0)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AudioFormatProperties.self, from: data)

        #expect(decoded.bitsPerChannel == nil)
        #expect(decoded.bitRate == nil)
    }
}

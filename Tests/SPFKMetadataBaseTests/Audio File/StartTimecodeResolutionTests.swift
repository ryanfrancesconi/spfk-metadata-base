// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import SPFKVideo
import SwiftTimecode
import Testing

@testable import SPFKMetadataBase

/// Four carriers can each state a start timecode and they can disagree, so the order they are
/// consulted in is the whole behavior.
@Suite
final class StartTimecodeResolutionTests {
    private let url = URL(fileURLWithPath: "/tmp/start-timecode-test.wav")

    private func description(
        timecodeTrack: String? = nil,
        trackFrameRate: TimecodeFrameRate? = .fps29_97d,
        bextSamples: UInt64? = nil,
        sampleRate: Double = 48000,
        infoTag: String? = nil
    ) -> MetaAudioFileDescription {
        var description = MetaAudioFileDescription(url: url)

        if let timecodeTrack {
            description.videoTrack = VideoTrackProperties(
                preciseFrameRate: trackFrameRate,
                startTimecodeString: timecodeTrack
            )
        }

        if let bextSamples {
            var bext = BEXTDescription()
            bext.timeReference = bextSamples
            bext.sampleRate = sampleRate
            description.bextDescription = bext
        }

        if let infoTag {
            description.tagProperties[.startTimecode] = infoTag
        }

        return description
    }

    private func resolve(
        _ description: MetaAudioFileDescription,
        xmp: Timecode? = nil,
        fallbackFrameRate: TimecodeFrameRate = .fps24
    ) -> StartTimecodeResolution? {
        description.resolvedStartTimecode(
            xmpStartTimecode: xmp,
            fallbackFrameRate: fallbackFrameRate
        )
    }

    // MARK: - Precedence

    @Test func timecodeTrackWinsOverEveryOtherCarrier() throws {
        let xmp = try Timecode(.string("02:00:00:00"), at: .fps25)

        let resolution = try #require(resolve(
            description(timecodeTrack: "01:00:00;01", bextSamples: 48000 * 3600, infoTag: "04:00:00:00"),
            xmp: xmp
        ))

        #expect(resolution.source == .timecodeTrack)
        #expect(resolution.timecode.stringValue() == "01:00:00;01")
        #expect(resolution.timecode.frameRate == .fps29_97d)
    }

    @Test func xmpWinsWhenThereIsNoTimecodeTrack() throws {
        let xmp = try Timecode(.string("02:00:00:00"), at: .fps25)

        let resolution = try #require(resolve(
            description(bextSamples: 48000 * 3600, infoTag: "04:00:00:00"),
            xmp: xmp
        ))

        #expect(resolution.source == .xmp)
        #expect(resolution.timecode.frameRate == .fps25)
    }

    @Test func bextWinsOverInfoTag() throws {
        let resolution = try #require(resolve(
            description(bextSamples: 48000 * 3600, infoTag: "04:00:00:00"),
            fallbackFrameRate: .fps25
        ))

        #expect(resolution.source == .broadcastWave)
        #expect(resolution.timecode.stringValue() == "01:00:00:00")
    }

    @Test func infoTagIsTheLastResort() throws {
        let resolution = try #require(resolve(
            description(infoTag: "04:00:00:00"),
            fallbackFrameRate: .fps25
        ))

        #expect(resolution.source == .infoTag)
        #expect(resolution.timecode.stringValue() == "04:00:00:00")
    }

    @Test func fileStatingNothingResolvesToNothing() {
        #expect(resolve(description()) == nil)
    }

    // MARK: - Presence versus zero

    /// A timecode track reading zero is a claim that the file starts at zero. Falling through to
    /// XMP there would offset a file that declared it shouldn't be.
    @Test func zeroTimecodeTrackStillWins() throws {
        let xmp = try Timecode(.string("02:00:00:00"), at: .fps25)

        let resolution = try #require(resolve(
            description(timecodeTrack: "00:00:00:00", trackFrameRate: .fps30),
            xmp: xmp
        ))

        #expect(resolution.source == .timecodeTrack)
        #expect(resolution.timecode.realTimeValue == 0)
    }

    /// BWF is the exception: an all-zero `timeReference` is the spec's placeholder for "not set",
    /// which `validated()` already encodes. Treating it as a real zero would stop an INFO tag from
    /// ever being reached on a file carrying an empty `bext`.
    @Test func allZeroBextIsTreatedAsAbsent() throws {
        let resolution = try #require(resolve(
            description(bextSamples: 0, infoTag: "04:00:00:00"),
            fallbackFrameRate: .fps25
        ))

        #expect(resolution.source == .infoTag)
    }

    // MARK: - Conversion

    /// `timeReference` is assembled from two 32-bit words, so a value above 2^32 exercises the
    /// high-word shift rather than only the low one. 48 kHz overflows 32 bits at just over 24 hours.
    @Test func bextConvertsSampleCountsAboveThirtyTwoBits() throws {
        let samples: UInt64 = 48000 * 25 * 3600
        try #require(samples > UInt64(UInt32.max))

        let resolution = try #require(resolve(
            description(bextSamples: samples),
            fallbackFrameRate: .fps25
        ))

        #expect(resolution.source == .broadcastWave)

        // 25 hours since midnight wraps the 24-hour SMPTE clock to 1 hour.
        #expect(resolution.timecode.stringValue() == "01:00:00:00")
    }

    /// `bext` stores a bare sample count and `TCOD`'s format is unspecified, so neither states a
    /// rate — the caller's supplies it, and a different one renders a different string.
    @Test func fallbackFrameRateAppliesOnlyToRatelessCarriers() throws {
        var bext = BEXTDescription()
        bext.timeReference = 48000 * 10 + 24000
        bext.sampleRate = 48000

        var description = MetaAudioFileDescription(url: url)
        description.bextDescription = bext

        let at25 = try #require(resolve(description, fallbackFrameRate: .fps25))
        let at30 = try #require(resolve(description, fallbackFrameRate: .fps30))

        #expect(at25.timecode.stringValue() == "00:00:10:12")
        #expect(at30.timecode.stringValue() == "00:00:10:15")
    }

    /// An unparseable INFO value is an absent start, not a zero one.
    @Test func malformedInfoTagResolvesToNothing() {
        #expect(resolve(description(infoTag: "not a timecode")) == nil)
        #expect(resolve(description(infoTag: "01:00:00:99"), fallbackFrameRate: .fps25) == nil)
    }
}

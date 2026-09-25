// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import Testing

@testable import SPFKMetadataBase

struct MetaAudioFileDescriptionPropertyTests {
    @Test func loudnessDescriptionFromTags() {
        var maf = MetaAudioFileDescription(url: URL(filePath: "/tmp/test.wav"))
        maf.tagProperties.tags[.loudnessIntegrated] = "-14.0"
        maf.tagProperties.tags[.loudnessRange] = "9.5"
        maf.tagProperties.tags[.loudnessTruePeak] = "-1.0"
        maf.tagProperties.tags[.loudnessMaxMomentary] = "-10.0"
        maf.tagProperties.tags[.loudnessMaxShortTerm] = "-12.0"

        let desc = maf.loudnessDescription
        #expect(desc.loudnessIntegrated == -14.0)
        #expect(desc.loudnessRange == 9.5)
        #expect(desc.maxTruePeakLevel == -1.0)
        #expect(desc.maxMomentaryLoudness == -10.0)
        #expect(desc.maxShortTermLoudness == -12.0)
    }

    @Test func loudnessDescriptionEmpty() {
        let maf = MetaAudioFileDescription(url: URL(filePath: "/tmp/test.wav"))
        let desc = maf.loudnessDescription
        #expect(desc.loudnessIntegrated == nil)
        #expect(desc.loudnessRange == nil)
        #expect(desc.maxTruePeakLevel == nil)
    }

    @Test func isAVPlayablePersisted() throws {
        var original = MetaAudioFileDescription(url: URL(filePath: "/tmp/test.wav"))
        original.isAVPlayable = false

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MetaAudioFileDescription.self, from: data)

        #expect(decoded.isAVPlayable == false)
    }

    @Test func codableRoundTripWithOptionals() throws {
        var original = MetaAudioFileDescription(
            url: URL(filePath: "/tmp/test.wav"),
            audioFormat: AudioFormatProperties(channelCount: 2, sampleRate: 48000, duration: 60),
            xmpMetadata: "<xmp>data</xmp>",
            iXMLMetadata: "<ixml>data</ixml>"
        )

        original.tagProperties.tags[.title] = "Test"
        original.markerCollection = AudioMarkerDescriptionCollection(markerDescriptions: [
            AudioMarkerDescription(name: "Cue", startTime: 1.0)
        ])

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MetaAudioFileDescription.self, from: data)

        #expect(decoded.audioFormat?.sampleRate == 48000)
        #expect(decoded.audioFormat?.channelCount == 2)
        #expect(decoded.xmpMetadata == "<xmp>data</xmp>")
        #expect(decoded.iXMLMetadata == "<ixml>data</ixml>")
        #expect(decoded.tagProperties.tags[.title] == "Test")
        #expect(decoded.markerCollection.count == 1)
    }
}

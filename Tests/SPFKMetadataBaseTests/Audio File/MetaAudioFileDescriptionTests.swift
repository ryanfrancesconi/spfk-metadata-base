// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKAudioBase
import Testing

@testable import SPFKMetadataBase

struct MetaAudioFileDescriptionTests {
    // MARK: - Helpers

    private func makeDescription(url: URL = URL(fileURLWithPath: "/tmp/test.wav")) -> MetaAudioFileDescription {
        MetaAudioFileDescription(url: url)
    }

    private func makeDescription(markerNames: [String], filename: String = "test.wav") -> MetaAudioFileDescription {
        let markers = markerNames.enumerated().map { i, name in
            AudioMarkerDescription(name: name, startTime: TimeInterval(i))
        }
        return MetaAudioFileDescription(
            url: URL(fileURLWithPath: "/tmp/\(filename)"),
            markerCollection: AudioMarkerDescriptionCollection(markerDescriptions: markers)
        )
    }

    // MARK: - Tag Accessors

    @Test func tagForKey() {
        var desc = makeDescription()
        desc.tagProperties.set(tag: .title, value: "My Title")

        #expect(desc.tag(for: .title) == "My Title")
    }

    @Test func tagForKeyMissing() {
        let desc = makeDescription()
        #expect(desc.tag(for: .title) == nil)
    }

    @Test func customTagForKey() {
        var desc = makeDescription()
        desc.tagProperties.set(customTag: "MYKEY", value: "Custom Value")

        #expect(desc.customTag(for: "MYKEY") == "Custom Value")
    }

    @Test func setTag() {
        var desc = makeDescription()
        desc.set(tag: .artist, value: "Artist Name")

        #expect(desc.tagProperties.tag(for: .artist) == "Artist Name")
    }

    @Test func setCustomTag() {
        var desc = makeDescription()
        desc.set(customTag: "CUSTOM", value: "value123")

        #expect(desc.tagProperties.customTag(for: "CUSTOM") == "value123")
    }

    // MARK: - merge(bext:)

    @Test func mergeBextCreatesDescriptionWhenNil() {
        var desc = makeDescription()
        #expect(desc.bextDescription == nil)

        desc.merge(bext: [.description: "Test Desc"])

        #expect(desc.bextDescription != nil)
        #expect(desc.bextDescription?[.description] == "Test Desc")
    }

    @Test func mergeBextMergesIntoExisting() {
        var desc = makeDescription()
        desc.bextDescription = BEXTDescription()
        desc.bextDescription?[.originator] = "Original"

        desc.merge(bext: [.description: "New Desc"])

        #expect(desc.bextDescription?[.originator] == "Original")
        #expect(desc.bextDescription?[.description] == "New Desc")
    }

    // MARK: - BPM Property

    @Test func bpmGetFromTag() {
        var desc = makeDescription()
        desc.tagProperties.set(tag: .bpm, value: "120.5")

        #expect(desc.bpm?.rawValue == 120.5)
    }

    @Test func bpmGetNilWhenNoTag() {
        let desc = makeDescription()
        #expect(desc.bpm == nil)
    }

    @Test func bpmSet() {
        var desc = makeDescription()
        desc.bpm = Bpm(140)!

        #expect(desc.tagProperties.tags[.bpm] != nil)
    }

    @Test func bpmSetNil() {
        var desc = makeDescription()
        desc.tagProperties.set(tag: .bpm, value: "120")
        desc.bpm = nil

        #expect(desc.tagProperties.tags[.bpm] == nil)
    }

    // MARK: - tempoMarker

    @Test func tempoMarkerParsesFromMarkerName() {
        let desc = makeDescription(markerNames: ["Tempo: 120"])
        #expect(desc.tempoMarker?.rawValue == 120)
    }

    @Test func tempoMarkerParsesFromFilename() {
        let desc = makeDescription(markerNames: [], filename: "120bpm_kick_drum.wav")
        #expect(desc.tempoMarker?.rawValue == 120)
    }

    @Test func tempoMarkerMarkerWinsOverFilename() {
        // Marker (160) should take priority over filename BPM (120)
        let desc = makeDescription(markerNames: ["Tempo: 160"], filename: "120bpm_loop.wav")
        #expect(desc.tempoMarker?.rawValue == 160)
    }

    @Test func tempoMarkerFirstMatchWins() {
        let desc = makeDescription(markerNames: ["Intro", "Tempo: 95", "Tempo: 110"])
        #expect(desc.tempoMarker?.rawValue == 95)
    }

    @Test func tempoMarkerNilWhenNoMatch() {
        let desc = makeDescription(url: URL(fileURLWithPath: "/tmp/kick_drum.wav"))
        #expect(desc.tempoMarker == nil)
    }

    // MARK: - Codable

    @Test func codableRoundTrip() throws {
        var original = makeDescription()
        original.fileType = .wav
        original.audioFormat = AudioFormatProperties(
            channelCount: 2, sampleRate: 44100, bitsPerChannel: 24, duration: 10.0
        )
        original.tagProperties.set(tag: .title, value: "Test Title")
        original.xmpMetadata = "<xmp>test</xmp>"
        original.iXMLMetadata = "<ixml>test</ixml>"

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MetaAudioFileDescription.self, from: data)

        #expect(decoded.url == original.url)
        #expect(decoded.fileType == original.fileType)
        #expect(decoded.audioFormat == original.audioFormat)
        #expect(decoded.tag(for: .title) == "Test Title")
        #expect(decoded.xmpMetadata == original.xmpMetadata)
        #expect(decoded.iXMLMetadata == original.iXMLMetadata)
    }

    @Test func codableNilOptionals() throws {
        let original = makeDescription()

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MetaAudioFileDescription.self, from: data)

        #expect(decoded.fileType == nil)
        #expect(decoded.audioFormat == nil)
        #expect(decoded.bextDescription == nil)
        #expect(decoded.xmpMetadata == nil)
        #expect(decoded.iXMLMetadata == nil)
    }

    // MARK: - isEqualExcludingImage

    @Test func isEqualExcludingImageTrueForIdentical() {
        let a = makeDescription()
        let b = makeDescription()

        #expect(a.isEqualExcludingImage(to: b))
    }

    @Test func isEqualExcludingImageTrueWhenOnlyImageDiffers() {
        var a = makeDescription()
        var b = makeDescription()

        // Give them different thumbnail data
        a.imageDescription.description = "Front Cover"
        b.imageDescription.description = "Back Cover"

        // Full equality should fail
        #expect(a != b)

        // But excluding image they should still match
        #expect(a.isEqualExcludingImage(to: b))
    }

    @Test func isEqualExcludingImageFalseWhenTagsDiffer() {
        var a = makeDescription()
        let b = makeDescription()

        a.set(tag: .title, value: "Different")

        #expect(!a.isEqualExcludingImage(to: b))
    }

    @Test func isEqualExcludingImageFalseWhenBextDiffers() {
        var a = makeDescription()
        let b = makeDescription()

        a.merge(bext: [.description: "BWF description"])

        #expect(!a.isEqualExcludingImage(to: b))
    }
}

// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKTesting
import Testing

@testable import SPFKMetadataBase

/// A protected file is one AVFoundation opens and reports playable, so the flag has to outrank
/// both playability answers rather than being folded into either.
@Suite
struct MediaFilePlayabilityTests {
    private struct Probe: MediaFilePlayability {
        var isAVPlayable: Bool
        var isDecodable: Bool
        var isProtected: Bool
    }

    @Test func protectionOutranksAnAVPlayableContainer() {
        let probe = Probe(isAVPlayable: true, isDecodable: false, isProtected: true)

        #expect(probe.isPlayable == false)
    }

    @Test func protectionOutranksADecodableContainer() {
        let probe = Probe(isAVPlayable: false, isDecodable: true, isProtected: true)

        #expect(probe.isPlayable == false)
    }

    @Test func anUnprotectedFileIsPlayableByEitherRoute() {
        #expect(Probe(isAVPlayable: true, isDecodable: false, isProtected: false).isPlayable)
        #expect(Probe(isAVPlayable: false, isDecodable: true, isProtected: false).isPlayable)
        #expect(Probe(isAVPlayable: false, isDecodable: false, isProtected: false).isPlayable == false)
    }

    /// Data written before the flag existed was accepted as playable, so its absence has to decode
    /// as unprotected rather than marking every existing element.
    @Test func olderDataWithoutTheFlagDecodesAsUnprotected() throws {
        let url = URL(fileURLWithPath: "/tmp/a.m4v")
        let json = #"{"url":"\#(url.absoluteString)","fileType":"m4v"}"#

        let decoded = try JSONDecoder().decode(MetaAudioFileDescription.self, from: Data(json.utf8))

        #expect(decoded.isProtected == false)
        #expect(decoded.isPlayable)
    }

    @Test func theFlagSurvivesARoundTrip() throws {
        var description = MetaAudioFileDescription(url: URL(fileURLWithPath: "/tmp/a.m4v"))
        description.isProtected = true

        let data = try JSONEncoder().encode(description)
        let decoded = try JSONDecoder().decode(MetaAudioFileDescription.self, from: data)

        #expect(decoded.isProtected)
        #expect(decoded.isPlayable == false)
    }
}

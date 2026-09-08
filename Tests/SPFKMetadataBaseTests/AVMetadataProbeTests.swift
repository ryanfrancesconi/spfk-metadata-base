// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import AVFoundation
import Foundation
import SPFKTesting
import SPFKVideo
import Testing

@testable import SPFKMetadataBase

/// What a container declares, as opposed to what one named keyspace happens to hold.
@Suite("AVMetadataProbe")
struct AVMetadataProbeTests {
    /// The gap the probe exists to close: `TagPropertiesAV.init` asks only for ID3, so a `.mov`
    /// reads as having no metadata while declaring a keyspace that does.
    @Test("Finds items the ID3-only read misses")
    func findsWhatTheID3ReadMisses() async throws {
        let url = TestBundleResources.shared.sample_mov

        let id3Only = try await TagPropertiesAV(url: url)
        #expect(id3Only.data.tags.isEmpty)

        let probe = try await TagPropertiesAV.probe(url: url)
        #expect(probe.formats.isNotEmpty)
        #expect(probe.items.isNotEmpty)
    }

    /// MXF's whole keyspace is provenance — application name, UMIDs, operational pattern — so
    /// nothing maps to a common key. **That is the measurement behind calling it untaggable**,
    /// rather than an assumption about the format.
    @Test("MXF declares items but no common keys", .enabled(if: ProVideoFormats.isAvailable))
    func mxfCarriesNoCommonKeys() async throws {
        let probe = try await TagPropertiesAV.probe(url: TestBundleResources.shared.sample_mxf)

        #expect(probe.formats.contains("org.smpte.mxf"))
        #expect(probe.items.isNotEmpty)
        #expect(probe.hasCommonKeys == false)

        // Provenance is what it does carry, and the muxer's name is the stable part of it.
        #expect(probe.items.contains { $0.value?.isEmpty == false })
    }

    /// An MP3's ID3 does map, which is what makes the negative above meaningful rather than a
    /// probe that never finds a common key for anything.
    @Test("An ID3 file does map to common keys")
    func id3MapsToCommonKeys() async throws {
        let probe = try await TagPropertiesAV.probe(url: TestBundleResources.shared.mp3_id3)

        #expect(probe.items.isNotEmpty)
        #expect(probe.hasCommonKeys)
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
@testable import SPFKMetadataBase
import Testing
import UniformTypeIdentifiers

@Suite("MetadataError")
struct MetadataErrorTests {
    let url = URL(fileURLWithPath: "/tmp/a.wav")
    let other = URL(fileURLWithPath: "/tmp/b.wav")

    @Test func unsupportedFormatNamesTheType() {
        #expect(
            MetadataError.unsupportedFormat(UTType(filenameExtension: "ogg"), .markers).errorDescription
                == "Unsupported file type for markers: OGG"
        )
        #expect(
            MetadataError.unsupportedFormat(nil, .artwork).errorDescription
                == "Unable to determine the file type for artwork"
        )
    }

    // The tag sentences are the ones conversion's failure report and ShadowTag already show.

    @Test func tagSentencesAreUnchanged() {
        #expect(MetadataError.readFailed(.tags, url).errorDescription == "Failed to load tag file: /tmp/a.wav")
        #expect(MetadataError.writeFailed(.tags, url).errorDescription == "Failed to update tags in /tmp/a.wav")
        #expect(
            MetadataError.copyFailed(.tags, from: url, to: other).errorDescription
                == "Failed to copy tags from /tmp/a.wav to /tmp/b.wav"
        )
        #expect(MetadataError.removeFailed(.tags, url).errorDescription == "Failed to removeAll tags in /tmp/a.wav")
    }

    @Test func writeSentencesAreUnchanged() {
        #expect(MetadataError.writeFailed(.bext, url).errorDescription == "Failed to write BEXT chunk to /tmp/a.wav")
        #expect(
            MetadataError.writeFailed(.xmp, url).errorDescription
                == "Failed to write the XMP packet to /tmp/a.wav"
        )
    }

    @Test func otherComponentsNameThemselves() {
        #expect(MetadataError.readFailed(.artwork, url).errorDescription == "Failed to read artwork from /tmp/a.wav")
        #expect(MetadataError.writeFailed(.markers, url).errorDescription == "Failed to write markers to /tmp/a.wav")
        #expect(MetadataError.removeFailed(.ixml, url).errorDescription == "Failed to remove iXML chunk from /tmp/a.wav")
        #expect(
            MetadataError.copyFailed(.rating, from: url, to: other).errorDescription
                == "Failed to copy the rating from /tmp/a.wav to /tmp/b.wav"
        )
    }

    @Test func equalityCoversComponentAndURL() {
        #expect(MetadataError.readFailed(.tags, url) == .readFailed(.tags, url))
        #expect(MetadataError.readFailed(.tags, url) != .readFailed(.bext, url))
        #expect(MetadataError.readFailed(.tags, url) != .readFailed(.tags, other))
        #expect(MetadataError.readFailed(.tags, url) != .writeFailed(.tags, url))
        #expect(MetadataError.unsupportedFormat(.mp3, .markers) != .unsupportedFormat(nil, .markers))
        #expect(MetadataError.saveFailed(url) != .saveFailed(other))
    }

    /// A save that wrote nothing, and a parse that could not open the file, name no component.
    @Test func wholeFileFailuresNameNoComponent() {
        #expect(MetadataError.saveFailed(url).errorDescription == "Failed to save /tmp/a.wav")
        #expect(MetadataError.openFailed(url).errorDescription == "Failed to open /tmp/a.wav")
    }

    /// The file type is any media type, so a video or image save can throw it too.
    @Test func unstorableNamesAnyMediaType() {
        #expect(MetadataError.unstorable(.mpeg4Movie, [.tags]).errorDescription == "MP4 files can't store metadata")
        #expect(MetadataError.unstorable(nil, [.markers]).errorDescription == "These files can't store markers")
    }

    @Test func surfacesThroughLocalizedDescription() {
        let error: Error = MetadataError.writeFailed(.tags, url)
        #expect(error.localizedDescription == "Failed to update tags in /tmp/a.wav")
    }
}

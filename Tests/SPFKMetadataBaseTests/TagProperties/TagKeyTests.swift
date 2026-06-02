import SPFKBase
import Foundation
import Testing

@testable import SPFKMetadataBase

// MARK: - TagKey Tests

struct TagKeyTests {
    // MARK: - taglibKey mapping

    @Test func taglibKeyDefaultIsUppercased() {
        #expect(TagKey.title.taglibKey == "TITLE")
        #expect(TagKey.album.taglibKey == "ALBUM")
        #expect(TagKey.artist.taglibKey == "ARTIST")
        #expect(TagKey.genre.taglibKey == "GENRE")
    }

    @Test func taglibKeyCustomOverrides() {
        #expect(TagKey.replayGainTrackGain.taglibKey == "REPLAYGAIN_TRACK_GAIN")
        #expect(TagKey.replayGainTrackPeak.taglibKey == "REPLAYGAIN_TRACK_PEAK")
        #expect(TagKey.replayGainTrackRange.taglibKey == "REPLAYGAIN_TRACK_RANGE")
        #expect(TagKey.replayGainAlbumGain.taglibKey == "REPLAYGAIN_ALBUM_GAIN")
        #expect(TagKey.replayGainAlbumPeak.taglibKey == "REPLAYGAIN_ALBUM_PEAK")
        #expect(TagKey.replayGainAlbumRange.taglibKey == "REPLAYGAIN_ALBUM_RANGE")
        #expect(TagKey.replayGainReferenceLoudness.taglibKey == "REPLAYGAIN_REFERENCE_LOUDNESS")
    }

    // MARK: - id3Frame mapping

    @Test func id3FrameMapping() {
        #expect(TagKey.title.id3Frame == .title)
        #expect(TagKey.album.id3Frame == .album)
        #expect(TagKey.artist.id3Frame == .artist)
        #expect(TagKey.bpm.id3Frame == .bpm)
        #expect(TagKey.comment.id3Frame == .comment)
        #expect(TagKey.composer.id3Frame == .composer)
        #expect(TagKey.genre.id3Frame == .genre)
        #expect(TagKey.trackNumber.id3Frame == .trackNumber)
    }

    @Test func userDefinedKeysMapToTXXX() {
        // loudness keys are non-standard and should map to .userDefined
        #expect(TagKey.loudnessIntegrated.id3Frame == .userDefined)
        #expect(TagKey.loudnessRange.id3Frame == .userDefined)
        #expect(TagKey.loudnessTruePeak.id3Frame == .userDefined)
        #expect(TagKey.replayGainTrackGain.id3Frame == .userDefined)
    }

    @Test func userDefinedKeysArray() {
        let userDefined = TagKey.userDefinedKeys
        #expect(userDefined.contains(.loudnessIntegrated))
        #expect(userDefined.contains(.replayGainTrackGain))
        #expect(!userDefined.contains(.title))
        #expect(!userDefined.contains(.album))
    }

    // MARK: - infoFrame mapping

    @Test func infoFrameMapping() {
        #expect(TagKey.title.infoFrame == .title)
        #expect(TagKey.artist.infoFrame == .artist)
        #expect(TagKey.comment.infoFrame == .comment)
        #expect(TagKey.copyright.infoFrame == .copyright)
        #expect(TagKey.genre.infoFrame == .genre)
        #expect(TagKey.album.infoFrame == .product)
        #expect(TagKey.trackNumber.infoFrame == .trackNumber1)
    }

    @Test func infoFrameNilForUnmapped() {
        // keys without INFO mapping should return nil
        #expect(TagKey.albumArtist.infoFrame == nil)
        #expect(TagKey.compilation.infoFrame == nil)
        #expect(TagKey.mood.infoFrame == nil)
    }

    @Test func infoAlternates() {
        let trackAlternates = TagKey.trackNumber.infoAlternates
        #expect(trackAlternates.contains(.trackNumber2))
        #expect(trackAlternates.contains(.trackNumber3))

        let languageAlternates = TagKey.language.infoAlternates
        #expect(languageAlternates.contains(.language2))
        #expect(languageAlternates.contains(.firstLanguage))
        #expect(languageAlternates.count == 10)

        // most keys have no alternates
        #expect(TagKey.title.infoAlternates.isEmpty)
    }

    // MARK: - Init from taglibKey

    @Test func initFromTaglibKey() {
        #expect(TagKey(taglibKey: "TITLE") == .title)
        #expect(TagKey(taglibKey: "ALBUM") == .album)
        #expect(TagKey(taglibKey: "ARTIST") == .artist)
        #expect(TagKey(taglibKey: "REPLAYGAIN_TRACK_GAIN") == .replayGainTrackGain)
    }

    @Test func initFromTaglibKeyNil() {
        #expect(TagKey(taglibKey: "NONEXISTENT") == nil)
        #expect(TagKey(taglibKey: "") == nil)
    }

    // MARK: - Init from displayName

    @Test func initFromDisplayName() {
        #expect(TagKey(displayName: "Title") == .title)
        #expect(TagKey(displayName: "Album") == .album)
        #expect(TagKey(displayName: "ISRC") == .isrc)
        #expect(TagKey(displayName: "Copyright URL") == .copyrightURL)
    }

    @Test func initFromDisplayNameNil() {
        #expect(TagKey(displayName: "Not A Real Tag") == nil)
    }

    // MARK: - Init from id3Frame

    @Test func initFromID3Frame() {
        #expect(TagKey(id3Frame: .title) == .title)
        #expect(TagKey(id3Frame: .album) == .album)
        #expect(TagKey(id3Frame: .artist) == .artist)
        #expect(TagKey(id3Frame: .bpm) == .bpm)
    }

    @Test func initFromID3FrameUserDefinedMatchesFirstKey() {
        // .userDefined is the fallback for many TagKeys, so init returns the first match
        let result = TagKey(id3Frame: .userDefined)
        #expect(result != nil)
    }

    // MARK: - Init from infoFrame

    @Test func initFromInfoFrame() {
        #expect(TagKey(infoFrame: .title) == .title)
        #expect(TagKey(infoFrame: .artist) == .artist)
        #expect(TagKey(infoFrame: .product) == .album)
    }

    @Test func initFromInfoFrameAlternates() {
        // trackNumber2 is an alternate for .trackNumber
        #expect(TagKey(infoFrame: .trackNumber2) == .trackNumber)
        #expect(TagKey(infoFrame: .trackNumber3) == .trackNumber)
        #expect(TagKey(infoFrame: .firstLanguage) == .language)
    }

    // MARK: - Init from string (case-insensitive)

    @Test func initFromStringExactRawValue() {
        #expect(TagKey(string: "bpm") == .bpm)
        #expect(TagKey(string: "artist") == .artist)
        #expect(TagKey(string: "title") == .title)
        #expect(TagKey(string: "initialKey") == .initialKey)
    }

    @Test func initFromStringUppercasedRawValue() {
        #expect(TagKey(string: "BPM") == .bpm)
        #expect(TagKey(string: "ARTIST") == .artist)
        #expect(TagKey(string: "TITLE") == .title)
    }

    @Test func initFromStringMixedCaseRawValue() {
        #expect(TagKey(string: "Bpm") == .bpm)
        #expect(TagKey(string: "Artist") == .artist)
        #expect(TagKey(string: "InitialKey") == .initialKey)
        #expect(TagKey(string: "INITIALKEY") == .initialKey)
    }

    @Test func initFromStringDisplayName() {
        #expect(TagKey(string: "Initial Key") == .initialKey)
        #expect(TagKey(string: "Album Artist") == .albumArtist)
        #expect(TagKey(string: "Loudness Integrated (LUFS)") == .loudnessIntegrated)
    }

    @Test func initFromStringDisplayNameCaseInsensitive() {
        #expect(TagKey(string: "initial key") == .initialKey)
        #expect(TagKey(string: "ALBUM ARTIST") == .albumArtist)
        #expect(TagKey(string: "loudness integrated (lufs)") == .loudnessIntegrated)
    }

    @Test func initFromStringID3Frame() {
        #expect(TagKey(string: "TBPM") == .bpm)
        #expect(TagKey(string: "TIT2") == .title)
        #expect(TagKey(string: "TPE1") == .artist)
    }

    @Test func initFromStringID3FrameLowercase() {
        #expect(TagKey(string: "tbpm") == .bpm)
        #expect(TagKey(string: "tit2") == .title)
        #expect(TagKey(string: "tpe1") == .artist)
    }

    @Test func initFromStringNil() {
        #expect(TagKey(string: "notakey") == nil)
        #expect(TagKey(string: "") == nil)
        #expect(TagKey(string: "???") == nil)
    }

    @Test func initFromStringRawValueRoundTrip() {
        for key in TagKey.allCases {
            #expect(TagKey(string: key.rawValue) == key, "Failed round-trip for \(key)")
        }
    }

    // MARK: - Comparable

    @Test func comparable() {
        #expect(TagKey.album < TagKey.title)
        #expect(TagKey.artist < TagKey.bpm)
        // same key is not less than itself
        #expect(!(TagKey.title < TagKey.title))
    }

    // MARK: - displayName

    @Test func displayNameCustomOverrides() {
        #expect(TagKey.copyrightURL.displayName == "Copyright URL")
        #expect(TagKey.podcastURL.displayName == "Podcast URL")
        #expect(TagKey.isrc.displayName == "ISRC")
        #expect(TagKey.loudnessIntegrated.displayName == "Loudness Integrated (LUFS)")
        #expect(TagKey.loudnessRange.displayName == "Loudness Range (LRA)")
        #expect(TagKey.loudnessTruePeak.displayName == "Loudness True Peak (dBTP)")
    }

    @Test func displayNameRoundTrip() {
        // all display names should round-trip via init(displayName:)
        for key in TagKey.allCases {
            let recovered = TagKey(displayName: key.displayName)
            #expect(recovered == key, "Failed round-trip for \(key)")
        }
    }

    // MARK: - description / readableDescription

    @Test func descriptionKey() {
        let key = TagKey.title
        let desc = key.descriptionKey
        #expect(desc.contains("Title"))
        #expect(desc.contains("ID3:"))
        #expect(desc.contains("TIT2"))
        #expect(desc.contains("INFO:"))
        #expect(desc.contains("INAM"))
    }

    @Test func descriptionKeyNoInfo() {
        // albumArtist has no INFO frame, so no INFO portion
        let desc = TagKey.albumArtist.descriptionKey
        #expect(desc.contains("ID3:"))
        #expect(!desc.contains("INFO:"))
    }

    @Test func readableDescription() {
        #expect(TagKey.album.readableDescription != nil)
        #expect(TagKey.loudnessIntegrated.readableDescription != nil)
        // many keys return nil
        #expect(TagKey.title.readableDescription == nil)
        #expect(TagKey.artist.readableDescription == nil)
    }

    @Test func descriptionIncludesReadable() {
        let desc = TagKey.album.description
        #expect(desc.contains(TagKey.album.descriptionKey))
        #expect(desc.contains(TagKey.album.readableDescription!))
    }
}

extension TagKeyTests {
    // MARK: - Development

    @Test func invalidID3() async throws {
        let invalidTags: [String: String] = ["TCOP": "2010 BOOM Library-Cinematic Metal Construction Kit", "TDOR": "2010", "TKEY": "impact_p0_brass_bell.wav", "TRCK": "0", "COMM": "Impact - Metal - Soft - High - Small. Brass bells. Dry. Original Pitch.", "TSSE": "Soundminer", "ARCHIVALLOCATION": "", "TPE1": "BOOM Library", "TALB": "Cinematic Metal Construction Kit", "TIT1": "www.boomlibrary.com", "TCON": "BELLS", "TOWN": "Cinematic Metal Construction Kit", "TIT2": "BELLMisc_Impact Brass Bell P0_B00M_CMCK.wav", "TPUB": "www.boomlibrary.com", "TPE2": "Cinematic Metal Construction Kit", "TDRC": "2010", "TIT3": "All sound effects are copyright BOOM Library - all rights reserved", "TOAL": "www.boomlibrary.com"]
    
        for item in invalidTags {
            if let key = ID3FrameKey(value: item.key) {
                Log.debug("ID3", key, item)
                continue
            }
            
            if let key = InfoFrameKey(value: item.key) {
                Log.debug("INFO", key, item)
                continue
            }
            
            let frame = TagKey(taglibKey: item.key)
            
            Log.debug(item, frame)

        }
    }
}

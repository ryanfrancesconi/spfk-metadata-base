// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata

import Foundation

extension TagKey {
    /// The ``TagGroup`` this key belongs to for UI display grouping.
    public var tagGroup: TagGroup {
        switch self {
        case .album, .artist, .comment, .copyright, .genre, .keywords, .mood, .title, .trackNumber, .subtitle:
            .common

        case .arranger, .bpm, .composer, .conductor, .initialKey, .instrumentation, .label, .lyrics, .lyricist,
             .originalLyricist, .movementName, .movementNumber, .remixer, .work, .owner:
            .music

        case .date, .releaseDate, .taggingDate, .originalDate, .encodingTime, .startTimecode, .endTimecode, .length:
            .dateAndTime

        case .ucsCategory, .ucsSubcategory, .ucsCatID:
            .ucs

        case .loudnessRange, .loudnessIntegrated, .loudnessMaxMomentary, .loudnessMaxShortTerm, .loudnessTruePeak:
            .loudness

        case .replayGainAlbumGain, .replayGainAlbumPeak, .replayGainAlbumRange, .replayGainReferenceLoudness,
             .replayGainTrackGain, .replayGainTrackPeak, .replayGainTrackRange:
            .replayGain

        case .artistWebpage, .audioSourceWebpage, .fileWebpage, .isrc, .paymentWebpage,
             .publisherWebpage, .radioStationWebpage, .encoding, .encodedBy:
            .utility

        default:
            .other
        }
    }
}

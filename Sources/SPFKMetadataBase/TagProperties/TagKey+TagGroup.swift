// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata

import Foundation

extension TagKey {
    /// The ``TagGroup`` this key belongs to for UI display grouping.
    public var tagGroup: TagGroup {
        switch self {
        case .album, .artist, .comment, .date, .genre, .keywords, .mood, .title, .trackNumber:
            .common

        case .arranger, .bpm, .composer, .conductor, .initialKey, .instrumentation, .label, .lyrics,
             .movementName, .movementNumber, .remixer, .work:
            .music

        case .ucsCategory, .ucsSubcategory, .ucsCatID:
            .ucs

        case .loudnessRange, .loudnessIntegrated, .loudnessMaxMomentary, .loudnessMaxShortTerm, .loudnessTruePeak:
            .loudness

        case .replayGainAlbumGain, .replayGainAlbumPeak, .replayGainAlbumRange, .replayGainReferenceLoudness,
             .replayGainTrackGain, .replayGainTrackPeak, .replayGainTrackRange:
            .replayGain

        case .artistWebpage, .audioSourceWebpage, .fileWebpage, .isrc, .paymentWebpage,
             .publisherWebpage, .radioStationWebpage, .releaseDate, .taggingDate:
            .utility

        default:
            .other
        }
    }
}

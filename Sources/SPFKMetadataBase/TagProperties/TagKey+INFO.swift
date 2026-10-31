// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation

// swiftformat:disable consecutiveSpaces

extension TagKey {
    /// Wave INFO frames as mapped to TagKey.
    ///
    /// Partial mapping of most common tags.
    public var infoFrame: InfoFrameKey? {
        switch self {
        case .album:            .product
        case .archivalLocation: .archivalLocation
        case .arranger:         .engineer
        case .artist:           .artist
        case .artistWebpage:    .baseURL
        case .bpm:              .bpm
        case .comment:          .comment
        case .commissioned:     .commissioned
        case .composer:         .musicBy
        case .copyright:        .copyright
        case .date:             .dateCreated
        case .discSubtitle:     .part
        case .encodedBy:        .technician
        case .encoding:         .software
        case .encodingTime:     .dateTimeOriginal
        case .genre:            .genre
        case .keywords:         .keywords
        case .label:            .publisher
        case .language:         .language
        case .length:           .length
        case .lyricist:         .writtenBy
        case .media:            .medium
        case .performer:        .starring
        case .rating:           .rating
        case .releaseCountry:   .country
        case .remixer:          .editedBy
        case .source:           .source
        case .startTimecode:    .startTimecode
        case .endTimecode:      .endTimecode
        case .subject:          .subject
        case .title:            .title
        case .trackNumber:      .trackNumber1
        default:
            nil
        }
    }

    public var infoAlternates: [InfoFrameKey] {
        switch self {
        case .encodedBy:
            [.encodedBy]

        case .trackNumber:
            [.trackNumber2, .trackNumber3]

        case .language:
            [.language2,
             .firstLanguage,
             .secondLanguage,
             .thirdLanguage,
             .fourthLanguage,
             .fifthLanguage,
             .sixthLanguage,
             .seventhLanguage,
             .eighthLanguage,
             .ninthLanguage]

        default:
            []
        }
    }
}

// swiftformat:enable consecutiveSpaces

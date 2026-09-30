// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation

extension TagKey {
    /// The associated ID3v2 label or TXXX if it is a non-standard frame
    public var id3Frame: ID3FrameKey {
        switch self {
        // `ID3FrameKey` spells it differently, and its raw values are `Codable`.
        case .copyrightURL: .copyrightUrl
        default: ID3FrameKey(rawValue: rawValue) ?? .userDefined
        }
    }
}

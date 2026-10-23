// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation

extension IXMLMetadata {
    /// A TRACK_LIST entry.
    public struct Track: Equatable, Sendable {
        /// 1-based input number on the recorder this track came from, which travels with the signal.
        public var channelIndex: String?

        /// 1-based position of the track in the file.
        public var interleaveIndex: String?

        /// Track name (e.g., "Boom", "Lav 1").
        public var name: String?

        /// Track function (e.g., "INPUT", "MIX").
        public var function: String?

        public init(
            channelIndex: String? = nil,
            interleaveIndex: String? = nil,
            name: String? = nil,
            function: String? = nil
        ) {
            self.channelIndex = channelIndex
            self.interleaveIndex = interleaveIndex
            self.name = name
            self.function = function
        }
    }
}

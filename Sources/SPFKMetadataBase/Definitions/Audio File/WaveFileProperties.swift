// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation

/// A WAV's format and BEXT chunk, without its tags, markers or artwork.
public struct WaveFileProperties: Hashable, Sendable {
    public var audioFormat: AudioFormatProperties
    public var bextDescription: BEXTDescription?

    public init(audioFormat: AudioFormatProperties, bextDescription: BEXTDescription? = nil) {
        self.audioFormat = audioFormat
        self.bextDescription = bextDescription
    }
}

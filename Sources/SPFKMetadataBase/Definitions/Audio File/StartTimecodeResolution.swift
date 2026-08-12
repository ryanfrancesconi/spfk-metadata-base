// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SwiftTimecode

/// Which metadata carrier a start timecode was read from.
public enum StartTimecodeSource: String, Hashable, Sendable, CaseIterable {
    /// A QuickTime/MP4 `tmcd` track, via ``VideoTrackProperties/startTimecode``.
    case timecodeTrack

    /// XMP Dynamic Media's `startTimecode`/`altTimecode`.
    case xmp

    /// A BWF `bext` chunk's `timeReference` sample count.
    case broadcastWave

    /// A RIFF INFO `TCOD` / ID3 tag string.
    case infoTag
}

/// A start timecode together with the carrier it came from.
public struct StartTimecodeResolution: Hashable, Sendable {
    /// The start position, at the frame rate its source stated — which is not necessarily the rate
    /// the file will be displayed at. A sink holding its own rate should convert rather than
    /// adopting this one.
    public let timecode: Timecode

    public let source: StartTimecodeSource

    public init(timecode: Timecode, source: StartTimecodeSource) {
        self.timecode = timecode
        self.source = source
    }
}

extension MetaAudioFileDescription {
    /// The file's start timecode, taking the first carrier that states one.
    ///
    /// Precedence is `tmcd` track, XMP, `bext`, then INFO/ID3 — descending order of how directly
    /// the carrier describes *this* file. The container's own timecode track wins because it is
    /// structural rather than authored, and cannot be a leftover from an editing session the way a
    /// copied XMP packet can.
    ///
    /// **A carrier stating `00:00:00:00` wins over a later one stating something else.** Presence
    /// is the test, not non-zero-ness: a file whose timecode track says it starts at zero is making
    /// a claim, and falling through to XMP there would offset a file that declared it shouldn't be.
    ///
    /// - Parameters:
    ///   - xmpStartTimecode: `XMPDynamicMedia.startTimecodeResolved`, or `nil` when the file has no
    ///     XMP packet. Not read from ``xmpMetadata`` here — parsing XMP lives a package away, and a
    ///     caller that has already parsed it should not pay for a second parse. Deliberately has no
    ///     default: XMP sits *between* two carriers this method reads itself, so a caller that
    ///     omits it silently gets different precedence rather than a missing last resort.
    ///   - fallbackFrameRate: The rate to interpret `bext` and INFO values at. Neither carrier
    ///     states one — `bext` stores a bare sample count and `TCOD`'s format is unspecified — so
    ///     without this they can be positioned in real time but never rendered as timecode.
    ///     Unused by the two carriers that state their own rate.
    public func resolvedStartTimecode(
        xmpStartTimecode: Timecode?,
        fallbackFrameRate: TimecodeFrameRate
    ) -> StartTimecodeResolution? {
        if let timecode = videoTrack?.startTimecode {
            return StartTimecodeResolution(timecode: timecode, source: .timecodeTrack)
        }

        if let xmpStartTimecode {
            return StartTimecodeResolution(timecode: xmpStartTimecode, source: .xmp)
        }

        // `validated()` rather than the raw chunk: an all-zero time reference is BWF's placeholder
        // for "not set", and treating it as a real zero start would stop XMP-less audio from ever
        // reaching the INFO tag below.
        if let seconds = bextDescription?.validated().timeReferenceInSeconds,
           seconds > 0
        {
            let timecode = Timecode(.realTime(seconds: seconds), at: fallbackFrameRate, by: .wrapping)
            return StartTimecodeResolution(timecode: timecode, source: .broadcastWave)
        }

        if let string = tagProperties[.startTimecode],
           let timecode = try? Timecode(.string(string), at: fallbackFrameRate),
           timecode.invalidComponents.isEmpty
        {
            return StartTimecodeResolution(timecode: timecode, source: .infoTag)
        }

        return nil
    }
}

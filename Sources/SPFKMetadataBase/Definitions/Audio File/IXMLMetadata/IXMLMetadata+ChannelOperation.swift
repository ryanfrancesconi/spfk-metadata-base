// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKAudioBase

extension IXMLMetadata.Track {
    /// iXML's FUNCTION values for a mid/side pair.
    public static let midFunction = "M-MID_SIDE"
    public static let sideFunction = "S-MID_SIDE"
}

extension IXMLMetadata {
    /// True for a two-track TRACK_LIST describing raw mid/side: the `M-MID_SIDE`/`S-MID_SIDE`
    /// functions, or the names M and S (or Mid and Side), in that order.
    public var describesMidSide: Bool {
        guard let tracks, tracks.count == 2 else { return false }

        if tracks[0].function == Track.midFunction, tracks[1].function == Track.sideFunction {
            return true
        }

        return Self.namesDescribeMidSide(tracks.map(\.name))
    }

    /// True for two names reading M and S, or Mid and Side, in that order, ignoring case and edge spaces.
    public static func namesDescribeMidSide(_ names: [String?]) -> Bool {
        guard names.count == 2 else { return false }

        func name(_ index: Int) -> String {
            (names[index] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }

        return ["m", "mid"].contains(name(0)) && ["s", "side"].contains(name(1))
    }

    /// Rewrites a two-track TRACK_LIST to describe the channels `operation` writes. Any other
    /// TRACK_LIST is left as it is.
    public mutating func applyChannelOperation(_ operation: ChannelOperation) {
        guard operation != .none, let tracks, tracks.count == 2 else { return }

        func positioned(_ list: [Track]) -> [Track] {
            list.enumerated().map { index, track in
                var track = track
                track.interleaveIndex = "\(index + 1)"
                return track
            }
        }

        let names = operation.laneNames(from: tracks.map { $0.name ?? "" })

        switch operation {
        case .none:
            return

        case .swap:
            self.tracks = positioned([tracks[1], tracks[0]])

        case .mono(.average):
            self.tracks = [Track(interleaveIndex: "1", name: names[0])]

        case .mono(.left):
            self.tracks = positioned([tracks[0]])

        case .mono(.right):
            self.tracks = positioned([tracks[1]])

        case .midSideDecode, .midSideEncode:
            let functions: [String?] = operation == .midSideEncode
                ? [Track.midFunction, Track.sideFunction]
                : [nil, nil]

            self.tracks = tracks.indices.map { i in
                var track = tracks[i]
                track.name = names[i]
                track.function = functions[i]
                return track
            }
        }
    }
}

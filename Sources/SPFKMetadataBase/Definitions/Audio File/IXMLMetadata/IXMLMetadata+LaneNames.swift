// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation

extension IXMLMetadata {
    /// The TRACK_LIST names in file channel order, `""` for a lane with no named track. Lane `i`
    /// is the track whose `interleaveIndex` is `i + 1`, or the `i`th track when none has one.
    public func laneNames(count: Int) -> [String] {
        let tracks = tracks ?? []

        return (0 ..< max(count, 0)).map { lane in
            Self.trackIndex(forLane: lane, in: tracks).flatMap { tracks[$0].name } ?? ""
        }
    }

    /// Names each lane's track, resolved as ``laneNames(count:)`` reads it, appending a track for a
    /// lane that has none. An empty name removes the track's NAME; tracks mapping to no lane are kept.
    public mutating func setLaneNames(_ names: [String]) {
        var list = tracks ?? []

        // Nothing to name, so no TRACK_LIST is created for it.
        guard list.isNotEmpty || names.contains(where: { !$0.isEmpty }) else { return }

        // In a list read by position, an interleave index on a new track would switch every later
        // read to index lookup, which the existing tracks cannot answer.
        let positional = list.isNotEmpty && !Self.hasInterleaveIndex(list)

        for (lane, name) in names.enumerated() {
            let value = name.isEmpty ? nil : name

            if let index = Self.trackIndex(forLane: lane, in: list) {
                list[index].name = value
            } else {
                list.append(Track(
                    channelIndex: "\(lane + 1)",
                    interleaveIndex: positional ? nil : "\(lane + 1)",
                    name: value
                ))
            }
        }

        tracks = list
    }

    private static func trackIndex(forLane lane: Int, in tracks: [Track]) -> Int? {
        guard hasInterleaveIndex(tracks) else {
            return lane < tracks.count ? lane : nil
        }

        return tracks.firstIndex { interleaveIndex(of: $0) == lane + 1 }
    }

    private static func hasInterleaveIndex(_ tracks: [Track]) -> Bool {
        tracks.contains { interleaveIndex(of: $0) != nil }
    }

    private static func interleaveIndex(of track: Track) -> Int? {
        guard let value: Int = number(track.interleaveIndex), value > 0 else { return nil }
        return value
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata

import Foundation
import SPFKAudioBase
import SPFKBase

/// Format-agnostic audio marker representing a point or region within an audio file.
///
/// Stores RIFF cue points, ID3 CHAP frames, or AVFoundation chapter markers in a unified
/// `Codable`, `Sendable` type. Ordered by start time (then name) for sorted collections.
public struct AudioMarkerDescription: Hashable, Sendable, Equatable, Comparable, Codable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs.markerID, rhs.markerID) {
        case let (id1?, id2?):
            return id1 == id2
        case (nil, nil):
            return lhs.name == rhs.name
                && lhs.startTime == rhs.startTime
                && lhs.endTime == rhs.endTime
                && lhs.markerType == rhs.markerType
        default:
            // One has an ID and the other doesn't — different identity types, never equal.
            // Treating them as equal would violate Hashable (they hash by different fields).
            return false
        }
    }

    public func hash(into hasher: inout Hasher) {
        if let markerID {
            hasher.combine(markerID)
        } else {
            hasher.combine(name)
            hasher.combine(startTime)
            hasher.combine(endTime)
            hasher.combine(markerType)
        }
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        guard lhs.startTime != rhs.startTime else {
            if let name1 = lhs.name, let name2 = rhs.name {
                return name1.standardCompare(with: name2)
            }

            // If either name is nil, they can't be ordered by name
            return false
        }

        return lhs.startTime < rhs.startTime
    }

    /// Display name of the marker.
    public var name: String?

    /// Start position in seconds.
    public var startTime: TimeInterval

    /// End position in seconds. Required for `.region` markers, nil for `.cue` markers.
    public var endTime: TimeInterval?

    /// Sample rate of the source file (used for sample-accurate positioning).
    public var sampleRate: Double?

    /// Unique ID within its collection, assigned automatically on insertion.
    public var markerID: Int?

    /// Optional display color as a hex string (e.g., "#FF0000").
    public var hexColor: HexColor?

    /// Structural type of this marker. Defaults to `.cue`.
    public var markerType: AudioMarkerType = .cue

    public var startTimeString: String {
        RealTimeDomain.string(seconds: startTime, showHours: .auto, showMilliseconds: true)
    }

    public init(
        name: String?,
        startTime: TimeInterval,
        endTime: TimeInterval? = nil,
        sampleRate: Double? = nil,
        markerID: Int? = nil,
        hexColor: HexColor? = nil,
        markerType: AudioMarkerType = .cue
    ) {
        self.name = name
        self.startTime = startTime.isNaN ? 0 : startTime
        self.endTime = endTime?.isNaN == true ? nil : endTime
        self.sampleRate = sampleRate
        self.markerID = markerID
        self.hexColor = hexColor
        self.markerType = markerType
    }
}

// MARK: - Codable

extension AudioMarkerDescription {
    enum CodingKeys: String, CodingKey {
        case name
        case startTime
        case endTime
        case sampleRate
        case markerID
        case hexColor
        case markerType
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        startTime = try container.decode(TimeInterval.self, forKey: .startTime)
        endTime = try container.decodeIfPresent(TimeInterval.self, forKey: .endTime)
        sampleRate = try container.decodeIfPresent(Double.self, forKey: .sampleRate)
        markerID = try container.decodeIfPresent(Int.self, forKey: .markerID)
        hexColor = try container.decodeIfPresent(HexColor.self, forKey: .hexColor)
        markerType = try container.decodeIfPresent(AudioMarkerType.self, forKey: .markerType) ?? .cue
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(startTime, forKey: .startTime)
        try container.encodeIfPresent(endTime, forKey: .endTime)
        try container.encodeIfPresent(sampleRate, forKey: .sampleRate)
        try container.encodeIfPresent(markerID, forKey: .markerID)
        try container.encodeIfPresent(hexColor, forKey: .hexColor)
        if markerType != .cue {
            try container.encode(markerType, forKey: .markerType)
        }
    }
}

// MARK: - CustomStringConvertible

extension AudioMarkerDescription: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        let name = name ?? "Untitled"
        let start = startTime.truncated(decimalPlaces: 3)

        var color = ""
        if let value = hexColor?.stringValue {
            color = ", Color: \(value)"
        }

        var id = ""
        if let markerID {
            id = ", ID: \(markerID)"
        }

        var end = ""
        if let endTime, endTime != startTime {
            end = "...\(endTime.truncated(decimalPlaces: 3))s"
        }

        var type = ""
        if markerType != .cue {
            type = ", Type: \(markerType.rawValue)"
        }

        return "\(name) @ \(start)s\(end)\(color)\(id)\(type)"
    }

    public var debugDescription: String {
        "AudioMarkerDescription(name: \(name ?? "nil"), startTime: \(startTime), "
            + "endTime: \(endTime?.string ?? "nil"), sampleRate: \(sampleRate?.string ?? "nil"), "
            + "markerID: \(markerID?.string ?? "nil"), hexColor: \(hexColor?.stringValue ?? "nil"), "
            + "markerType: \(markerType.rawValue))"
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata

import Foundation

// MARK: - Static Lookup Tables

extension TagKey {
    private static let taglibKeyMap: [String: TagKey] = Dictionary(
        allCases.map { ($0.taglibKey, $0) },
        uniquingKeysWith: { first, _ in first }
    )

    private static let displayNameMap: [String: TagKey] = Dictionary(
        uniqueKeysWithValues: allCases.map { ($0.displayName, $0) }
    )

    private static let lowercasedRawValueMap: [String: TagKey] = Dictionary(
        uniqueKeysWithValues: allCases.map { ($0.rawValue.lowercased(), $0) }
    )

    private static let lowercasedDisplayNameMap: [String: TagKey] = Dictionary(
        allCases.map { ($0.displayName.lowercased(), $0) },
        uniquingKeysWith: { first, _ in first }
    )

    private static let id3FrameMap: [ID3FrameKey: TagKey] = {
        var map = [ID3FrameKey: TagKey]()
        for key in allCases {
            // first match wins, matching previous behavior
            if map[key.id3Frame] == nil {
                map[key.id3Frame] = key
            }
        }
        return map
    }()

    private static let infoFrameMap: [InfoFrameKey: TagKey] = {
        var map = [InfoFrameKey: TagKey]()
        for key in allCases {
            if let frame = key.infoFrame, map[frame] == nil {
                map[frame] = key
            }
            for alt in key.infoAlternates where map[alt] == nil {
                map[alt] = key
            }
        }
        return map
    }()

    /// Keyed by uppercased ID3 frame identifier string (e.g. `"TBPM"`) → TagKey.
    private static let id3FrameValueMap: [String: TagKey] = {
        var map = [String: TagKey]()
        for key in allCases where map[key.id3Frame.value] == nil {
            map[key.id3Frame.value] = key
        }
        return map
    }()

    /// Keyed by uppercased INFO frame identifier string (e.g. `"IBPM"`) → TagKey.
    private static let infoFrameValueMap: [String: TagKey] = {
        var map = [String: TagKey]()
        for key in allCases {
            if let frame = key.infoFrame, map[frame.value] == nil {
                map[frame.value] = key
            }
            for alt in key.infoAlternates where map[alt.value] == nil {
                map[alt.value] = key
            }
        }
        return map
    }()
}

// MARK: - Initializers

extension TagKey {
    public init?(taglibKey: String) {
        guard let match = Self.taglibKeyMap[taglibKey] else { return nil }
        self = match
    }

    public init?(displayName: String) {
        guard let match = Self.displayNameMap[displayName] else { return nil }
        self = match
    }

    public init?(id3Frame: ID3FrameKey) {
        guard let match = Self.id3FrameMap[id3Frame] else { return nil }
        self = match
    }

    public init?(infoFrame: InfoFrameKey) {
        guard let match = Self.infoFrameMap[infoFrame] else { return nil }
        self = match
    }

    public init?(string: String) {
        let lowercased = string.lowercased()

        if let value = Self.lowercasedRawValueMap[lowercased] {
            self = value
            return
        }

        if let value = Self.lowercasedDisplayNameMap[lowercased] {
            self = value
            return
        }

        let uppercased = string.uppercased()

        if let value = Self.id3FrameValueMap[uppercased] {
            self = value
            return
        }

        if let value = Self.infoFrameValueMap[uppercased] {
            self = value
            return
        }

        return nil
    }
}

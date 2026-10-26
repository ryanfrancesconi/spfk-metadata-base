// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKAudioBase

extension TagKey {
    /// `value` as an edit stores it. A key ``MusicalKeyValue/parse(_:)`` reads is written in
    /// `notation`, keeping the source's spelling, or in `.standard` when `notation` cannot express
    /// it (a root alone on a wheel); "off" or "off key" becomes "o". Text that does not parse, and
    /// every other tag, is stored as given.
    ///
    /// The read paths (`set(taglibKey:)`, `set(id3Frame:)`, `set(infoFrame:)`) bypass this, so a key
    /// is rewritten only when something sets it.
    public func storedValue(_ value: String, notation: MusicalKeyNotation = .standard) -> String {
        guard self == .initialKey else { return value }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        if OrganizeMusicalKeyPlanner.offKeyValues.contains(trimmed.lowercased()) {
            return "o"
        }

        guard let parsed = MusicalKeyValue.parse(trimmed) else { return value }

        return parsed.string(in: notation) ?? parsed.string(in: .standard) ?? value
    }
}

extension TagPropertiesContainerModel {
    /// Sets the key tag in `notation`; see ``TagKey/storedValue(_:notation:)``. The generic setters
    /// store `.standard`.
    public mutating func setInitialKey(_ raw: String, notation: MusicalKeyNotation) {
        tags[.initialKey] = TagKey.initialKey.storedValue(raw, notation: notation)
    }
}

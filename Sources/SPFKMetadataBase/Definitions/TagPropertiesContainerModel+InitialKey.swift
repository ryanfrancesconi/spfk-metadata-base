// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKAudioBase

extension TagKey {
    /// `value` as an edit stores it. A key ``MusicalKeyValue/parse(_:)`` reads becomes the ID3v2.4
    /// `TKEY` short form ("C#m", "Dbm", "A"), keeping a flat spelling; "off" or "off key" becomes
    /// "o". Text that does not parse, and every other tag, is stored as given.
    ///
    /// The read paths (`set(taglibKey:)`, `set(id3Frame:)`, `set(infoFrame:)`) bypass this, so a key
    /// is rewritten only when something sets it.
    public func storedValue(_ value: String) -> String {
        guard self == .initialKey else { return value }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        if ["o", "off", "off key"].contains(trimmed.lowercased()) {
            return "o"
        }

        guard let parsed = MusicalKeyValue.parse(trimmed) else { return value }

        return parsed.value.string(in: .short, flats: parsed.usesFlats)
    }
}

extension TagPropertiesContainerModel {
    /// Sets the key tag in the short form; see ``TagKey/storedValue(_:)``.
    public mutating func setInitialKey(_ raw: String) {
        set(tag: .initialKey, value: raw)
    }
}

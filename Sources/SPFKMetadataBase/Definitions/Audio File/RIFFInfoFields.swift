// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKBase

/// A WAV's INFO fields that no ``TagKey`` maps, kept apart from the tags so a save writes them to
/// INFO alone and never copies them into ID3.
///
/// On a description, nil means not read and empty means read with none: a save of a nil value
/// leaves every such field in the file as it is.
public struct RIFFInfoFields: Hashable, Codable, Sendable {
    /// Keyed by the exact INFO ID, case included: `BCPR`, `itrk`, `ISRF`.
    public var fields: [String: String]

    /// The file's INFO title, where the tags' title came from ID3 and differs. Never written.
    public var infoTitle: String?

    /// The text of the file's DISP chunk. Never written.
    public var displayText: String?

    public init(fields: [String: String] = [:], infoTitle: String? = nil, displayText: String? = nil) {
        self.fields = fields
        self.infoTitle = infoTitle
        self.displayText = displayText
    }

    /// Sets a field as read from a file, without C0 control characters other than tab, line feed
    /// and carriage return.
    public mutating func set(field id: String, value: String) {
        fields[id] = value.removingC0ControlsExceptLineBreaksAndTabs
    }

    /// A field ID's spec name where ``InfoFrameKey`` knows it ("Source Form" for `ISRF`), the ID
    /// otherwise.
    public static func displayName(for id: String) -> String {
        InfoFrameKey(value: id)?.displayName ?? id
    }

    /// False for an ID with a lowercase letter, which no INFO spec defines.
    public static func isEditable(id: String) -> Bool {
        !id.contains { $0.isASCII && $0.isLowercase }
    }

    /// The field changes that turn `other` into these, named `INFO: <display name>` and sorted
    /// by name.
    public func difference(from other: RIFFInfoFields) -> [TagValueChange] {
        Set(fields.keys).union(other.fields.keys)
            .filter { fields[$0] != other.fields[$0] }
            .map { TagValueChange(name: "INFO: \(Self.displayName(for: $0))", before: other.fields[$0] ?? "", after: fields[$0] ?? "") }
            .sorted { $0.name.standardCompare(with: $1.name) }
    }

    /// Whether a custom tag spelled `key` is the custom tag an older read made of field `id`:
    /// the ID itself in any case, or the TagLib name of a named frame (`SOURCEFORM` for `ISRF`).
    public static func customTag(_ key: String, names id: String) -> Bool {
        let key = key.uppercased()
        return key == id.uppercased() || InfoFrameKey(value: id)?.taglibKey == key
    }
}

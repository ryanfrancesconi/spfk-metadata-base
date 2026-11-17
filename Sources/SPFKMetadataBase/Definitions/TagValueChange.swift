// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKBase
import SPFKUtils

/// One tag value that differs between two ``TagData`` instances.
///
/// An absent key is carried as `""` rather than `nil`, so an added and a cleared value are both
/// ordinary changes with one side empty.
public struct TagValueChange: Hashable, Sendable {
    /// Identifies the field within its store: a ``TagKey`` raw value, or ``customKeyPrefix`` plus
    /// the raw key for a custom tag. Read it with ``tagKey`` and ``customTagKey``.
    public let key: String

    /// User-facing name of the field: a ``TagKey/displayName``, or the raw key for a custom tag.
    public let name: String

    public let before: String
    public let after: String

    public init(key: String, name: String, before: String, after: String) {
        self.key = key
        self.name = name
        self.before = before
        self.after = after
    }

    /// A change whose key is its name.
    public init(name: String, before: String, after: String) {
        self.init(key: name, name: name, before: before, after: after)
    }

    /// Prefixes a custom tag's key, which could otherwise equal a ``TagKey`` raw value.
    public static let customKeyPrefix = "custom:"

    /// The standard tag this change names, if any.
    public var tagKey: TagKey? {
        key.hasPrefix(Self.customKeyPrefix) ? nil : TagKey(rawValue: key)
    }

    /// The custom tag this change names, if any.
    public var customTagKey: String? {
        key.hasPrefix(Self.customKeyPrefix) ? String(key.dropFirst(Self.customKeyPrefix.count)) : nil
    }
}

extension TagData {
    /// The changes that turn `other` into `self`, sorted by field name.
    ///
    /// Keys are unioned rather than intersected, and an absent value counts as `""` -- the same
    /// convention as ``divergentTagKeyDisplayNames()``. A key present on one side only is the
    /// change a caller most needs to see, not one to skip.
    public func difference(from other: TagData) -> [TagValueChange] {
        var changes = [TagValueChange]()

        for key in Set(tags.keys).union(other.tags.keys) {
            let before = other.tags[key] ?? ""
            let after = tags[key] ?? ""

            if before != after {
                changes.append(TagValueChange(key: key.rawValue, name: key.displayName, before: before, after: after))
            }
        }

        for key in Set(customTags.keys).union(other.customTags.keys) {
            let before = other.customTags[key] ?? ""
            let after = customTags[key] ?? ""

            if before != after {
                changes.append(TagValueChange(key: Self.customKey(key), name: key, before: before, after: after))
            }
        }

        return changes.sorted { $0.name < $1.name }
    }

    /// The ``TagValueChange/key`` of custom tag `key`.
    public static func customKey(_ key: String) -> String {
        TagValueChange.customKeyPrefix + key
    }
}

extension TagProperties {
    /// The tag changes that turn `other` into `self`, sorted by field name.
    ///
    /// Compares tags only. ``audioProperties`` describes the audio stream rather than anything a
    /// user edited, so a difference there is not a change they can be asked about.
    public func difference(from other: TagProperties) -> [TagValueChange] {
        data.difference(from: other.data)
    }
}

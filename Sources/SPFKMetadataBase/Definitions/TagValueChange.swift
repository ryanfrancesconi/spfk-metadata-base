// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKBase
import SPFKUtils

/// One tag value that differs between two ``TagData`` instances.
///
/// An absent key is carried as `""` rather than `nil`, so an added and a cleared value are both
/// ordinary changes with one side empty.
public struct TagValueChange: Hashable, Sendable {
    /// User-facing name of the field: a ``TagKey/displayName``, or the raw key for a custom tag.
    public let name: String

    public let before: String
    public let after: String

    public init(name: String, before: String, after: String) {
        self.name = name
        self.before = before
        self.after = after
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
                changes.append(TagValueChange(name: key.displayName, before: before, after: after))
            }
        }

        for key in Set(customTags.keys).union(other.customTags.keys) {
            let before = other.customTags[key] ?? ""
            let after = customTags[key] ?? ""

            if before != after {
                changes.append(TagValueChange(name: key, before: before, after: after))
            }
        }

        return changes.sorted { $0.name < $1.name }
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

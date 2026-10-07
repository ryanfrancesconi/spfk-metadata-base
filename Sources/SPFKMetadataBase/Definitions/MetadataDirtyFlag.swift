// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

/// Identifies which aspects of an audio file's metadata have unsaved changes.
///
/// Used as a `Set<MetadataDirtyFlag>` to track what needs writing.
/// The save orchestration layer decides which subsystem handles each flag.
///
/// **Declaration order is a storage format.** The set is persisted as a bitmask whose bit is the
/// case's position in `allCases`, so a new case goes on the end and an existing one never moves.
/// The raw values are persisted too; renaming a case is a data migration.
public enum MetadataDirtyFlag: String, CaseIterable, Hashable, Sendable, Codable {
    /// Tags, BEXT and iXML
    case metadata
    /// Embedded artwork
    case image
    /// Embedded XMP — written by a separate XMP call
    case xmp
    /// Markers, which some formats store as chapters
    case markers

    /// Finder color/label changed. Stored in extended attributes rather than in the file, so it
    /// is the one flag an external attribute change can overwrite.
    ///
    /// The lock is deliberately not one of these: it is applied to the file immediately rather
    /// than becoming a pending change, so there is never a pending lock for a refresh to discard.
    case finderTags
}

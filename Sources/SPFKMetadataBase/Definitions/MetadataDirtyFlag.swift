// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

/// Identifies which aspects of an audio file's metadata have unsaved changes.
///
/// Used as a `Set<MetadataDirtyFlag>` to track what needs writing.
/// The save orchestration layer decides which subsystem handles each flag.
///
/// **Declaration order is a storage format.** The set is persisted as a bitmask whose bit is the
/// case's position in `allCases`, so a new case goes on the end and an existing one never moves.
public enum MetadataDirtyFlag: String, CaseIterable, Hashable, Sendable, Codable {
    /// Tags, BEXT, iXML — one MetaAudioFileDescription.save() call
    case metadata
    /// Embedded artwork
    case image
    /// XMP sidecar — separate XMP write call
    case xmp
    /// Markers — format-specific write (WaveFileC for WAV, chapter utils for others)
    case markers

    /// Finder color/label changed. Stored in extended attributes rather than in the file.
    case finderTags

    /// The `uchg` lock flag changed. A BSD file flag rather than anything in the data stream, and
    /// applied by `save` around the other writes: clearing it comes first, since every write below
    /// depends on it, and setting it comes last, for the same reason.
    case lock
}

extension MetadataDirtyFlag {
    /// The flags an attributes-only external change can overwrite -- those held outside the file's
    /// data stream, where refreshing from disk replaces them wholesale.
    ///
    /// `.metadata`, `.image`, `.xmp` and `.markers` all live in the data stream, which an
    /// attributes-only change does not touch. A file observer conflicts on this set and refreshes
    /// otherwise; conflicting regardless would mark a whole playlist over a Finder tag write.
    public static let attributeBacked: Set<MetadataDirtyFlag> = [.finderTags, .lock]
}

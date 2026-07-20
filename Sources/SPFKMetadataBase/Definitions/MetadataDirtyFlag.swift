// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

/// Identifies which aspects of an audio file's metadata have unsaved changes.
///
/// Used as a `Set<MetadataDirtyFlag>` to track what needs writing.
/// The save orchestration layer decides which subsystem handles each flag.
public enum MetadataDirtyFlag: String, Hashable, Sendable, Codable {
    /// Tags, BEXT, iXML — one MetaAudioFileDescription.save() call
    case metadata
    /// Embedded artwork
    case image
    /// XMP sidecar — separate XMP write call
    case xmp
    /// Markers — format-specific write (WaveFileC for WAV, chapter utils for others)
    case markers
}

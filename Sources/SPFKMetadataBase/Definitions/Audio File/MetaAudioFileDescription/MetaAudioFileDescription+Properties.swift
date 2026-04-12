// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata

import CoreImage
import Foundation
import SPFKAudioBase

extension MetaAudioFileDescription {
    /// Returns the best available image for display: embedded artwork (from a fresh parse),
    /// then the cached thumbnail (hydrated from `ImageDataStore` at load time), then the
    /// file's Finder Quick Look thumbnail as a last resort.
    public var bestAvailableImage: CGImage? {
        imageDescription.cgImage ?? url.bestImageRepresentation?.cgImage
    }
    
    public var bestOriginalImage: CGImage? {
        imageDescription.cgImage ?? imageDescription.thumbnailImage
    }

    /// The BPM (beats per minute) value from the `.bpm` tag. Setting this updates the underlying tag string.
    public var bpm: Bpm? {
        get {
            guard let rawValue = tagProperties[.bpm]?.double else {
                return nil
            }

            return Bpm(rawValue)
        }

        set {
            tagProperties[.bpm] = newValue?.stringValue
        }
    }

    /// Infers a BPM from embedded audio markers and the filename when no explicit `.bpm` tag is present.
    ///
    /// Searches marker names first (e.g. Logic's "Tempo: 120" marker), then the filename stem.
    /// Recognized patterns (case-insensitive): `Tempo: 120`, `Tempo 120`, `BPM 120`, `BPM120`,
    /// `120 BPM`, `120bpm`.
    public var tempoMarker: Bpm? {
        let candidates = markerCollection.markerDescriptions.compactMap(\.name)
            + [url.deletingPathExtension().lastPathComponent]
        return candidates.lazy.compactMap { Bpm(tempoString: $0) }.first
    }

    /// Loudness values assembled from ID3/TXXX loudness tags (not from the BEXT chunk).
    public var loudnessDescription: LoudnessDescription {
        LoudnessDescription(
            loudnessIntegrated: tagProperties[.loudnessIntegrated]?.double,
            loudnessRange: tagProperties[.loudnessRange]?.double,
            maxTruePeakLevel: tagProperties[.loudnessTruePeak]?.float,
            maxMomentaryLoudness: tagProperties[.loudnessMaxMomentary]?.double,
            maxShortTermLoudness: tagProperties[.loudnessMaxShortTerm]?.double,
        )
    }
}

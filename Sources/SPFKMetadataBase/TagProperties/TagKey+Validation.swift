// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata

import Foundation
import SPFKAudioBase
import SPFKBase

/// Describes how a tag value string should be validated and clamped.
public enum TagValueConstraint: Sendable {
    /// Parse as `Int`, clamp to range, serialize back to `String`.
    case intClamped(ClosedRange<Int>)

    /// Validate as a BPM value: clamp to ``Bpm/tempoRange`` with octave-folding for out-of-range values.
    case bpm
}

extension TagValueConstraint {
    /// Applies the constraint to `value`.
    ///
    /// Returns the corrected string if `value` needs to change, or `nil` if the value is already
    /// valid or is not parseable as the expected type (leave original unchanged in both cases).
    public func apply(to value: String) -> String? {
        switch self {
        case .intClamped(let range):
            guard let int = Int(value) else { return nil }
            let clamped = int.clamped(to: range)
            return clamped == int ? nil : String(clamped)

        case .bpm:
            guard let double = Double(value),
                  let validated = Bpm.validate(double)
            else { return nil }
            return validated.stringValue != value ? validated.stringValue : nil
        }
    }
}

extension TagKey {
    /// The validation constraint for this key, or `nil` if values are accepted as-is.
    public var valueConstraint: TagValueConstraint? {
        switch self {
        case .rating:   .intClamped(TagKey.ratingRange)
        case .bpm:      .bpm
        default:        nil
        }
    }
}

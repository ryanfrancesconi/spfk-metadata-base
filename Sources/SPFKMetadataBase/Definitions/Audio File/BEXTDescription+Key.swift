// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base
// swiftformat:disable consecutiveSpaces

import Foundation
import OrderedCollections
import SPFKAudioBase
import SPFKBase
import SPFKUtils

/// Dictionary type mapping ``BEXTDescription/Key`` values to optional string representations.
public typealias BEXTKeyDictionary = OrderedDictionary<BEXTDescription.Key, String?>

extension BEXTDescription {
    /// Enumeration of BEXT chunk field identifiers for dictionary-style access via ``BEXTDescription/subscript(key:)``.
    public enum Key: Sendable, CaseIterable {
        case originator
        case originatorReference
        case originationDate
        case originationTime
        case timeReferenceSamples
        case timeReferenceString
        case umid
        case description
        case loudnessIntegrated
        case loudnessRange
        case maxTruePeakLevel
        case maxMomentaryLoudness
        case maxShortTermLoudness
        case version
        case codingHistory

        /// Whether this field can be edited by the user. Version and the formatted time reference are read-only.
        public var isEditable: Bool {
            self != .version && self != .timeReferenceString
        }

        /// Whether this field holds a number, which an empty value clears.
        public var isNumeric: Bool {
            switch self {
            case .loudnessIntegrated, .loudnessRange, .maxTruePeakLevel, .maxMomentaryLoudness,
                 .maxShortTermLoudness, .timeReferenceSamples:
                true
            default:
                false
            }
        }

        /// Whether setting `value` takes effect: always for text, and for a number when it is empty or parses.
        public func accepts(_ value: String?) -> Bool {
            guard isNumeric, let value, value.isNotEmpty else { return true }

            switch self {
            case .maxTruePeakLevel: return value.float != nil
            case .timeReferenceSamples: return value.uInt64 != nil
            default: return value.double != nil
            }
        }

        /// Whether this field typically contains multi-line text and should use a multi-line editor.
        public var isMultiLine: Bool {
            self == .description || self == .codingHistory
        }

        /// Human-readable label for UI display.
        public var displayName: String {
            switch self {
            case .originator: "Originator"
            case .originatorReference: "Originator Reference"
            case .originationDate: "Origination Date"
            case .originationTime: "Origination Time"
            case .timeReferenceSamples: "Time Reference Samples"
            case .timeReferenceString: "Time Reference"
            case .umid: "UMID"
            case .description: "Description"
            case .loudnessIntegrated: TagKey.loudnessIntegrated.displayName
            case .loudnessRange: TagKey.loudnessRange.displayName
            case .maxTruePeakLevel: TagKey.loudnessTruePeak.displayName
            case .maxMomentaryLoudness: TagKey.loudnessMaxMomentary.displayName
            case .maxShortTermLoudness: TagKey.loudnessMaxShortTerm.displayName
            case .version: "Version"
            case .codingHistory: "Coding History"
            }
        }

        /// Detailed description of the field per the EBU Tech 3285 specification.
        public var description: String {
            switch self {
            case .originator:
                "Contains the name of the originator / producer of the audio file. (maximum 32 characters)"
            case .originatorReference:
                "Contains an unambiguous reference allocated by the originating organization."
            case .originationDate:
                "10 characters containing the date of creation of the audio sequence. The format shall be « ‘,year’,-,’month,’-‘,day,’» with 4 characters for the year and 2 characters per other item. Year is defined from 0000 to 9999 Month is defined from 1 to 12 Day is defined from 1 to 28, 29, 30 or 31 The separator between the items can be anything but it is recommended that one of the following characters be used: ‘-’  hyphen  ‘_’  underscore  ‘:’  colon  ‘ ’  space  ‘.’  stop."
            case .originationTime:
                "8 ASCII characters containing the time of creation of the audio sequence. The format shall be « ‘hour’-‘minute’-‘second’» with 2 characters per item. Hour is defined from 0 to 23. Minute and second are defined from 0 to 59. The separator between the items can be anything but it is recommended that one of the following characters be used: ‘-’  hyphen  ‘_’  underscore  ‘:’  colon  ‘ ’  space  ‘.’  stop."
            case .timeReferenceSamples:
                ""
            case .timeReferenceString:
                "These fields shall contain the time-code of the sequence. It is a 64-bit value which contains the first sample count since midnight. The number of samples per second depends on the sample frequency which is defined in the field <nSamplesPerSec> from the <format chunk>."
            case .umid:
                "Unique Material Identifier"
            case .description:
                "ASCII string (maximum 256 characters) containing a free description of the sequence. To help applications which display only a short description, it is recommended that a resume of the description is contained in the first 64 characters and the last 192 characters are used for details."
            case .loudnessIntegrated:
                TagKey.loudnessIntegrated.readableDescription ?? ""
            case .loudnessRange:
                TagKey.loudnessRange.readableDescription ?? ""
            case .maxTruePeakLevel:
                TagKey.loudnessTruePeak.readableDescription ?? ""
            case .maxMomentaryLoudness:
                TagKey.loudnessMaxMomentary.readableDescription ?? ""
            case .maxShortTermLoudness:
                TagKey.loudnessMaxShortTerm.readableDescription ?? ""
            case .version:
                "Version of the BWF"
            case .codingHistory:
                ""
            }
        }

        public init?(displayName: String) {
            for item in Self.allCases where item.displayName == displayName {
                self = item
                return
            }

            return nil
        }
    }
}

extension BEXTDescription {
    /// Gets or sets a BEXT field value by its ``Key``.
    public subscript(key: BEXTDescription.Key) -> String? {
        get {
            guard let value = dictionary[key] else { return nil }
            return value
        }

        set {
            apply(newValue, for: key)
        }
    }

    /// All BEXT fields as an ordered key-value dictionary. Setting this updates the underlying properties.
    public var dictionary: BEXTKeyDictionary {
        get {
            [
                .originator: originator,
                .originatorReference: originatorReference,
                .originationDate: originationDate,
                .originationTime: originationTime,
                .timeReferenceSamples: timeReference?.string,
                .timeReferenceString: timeReferenceString,
                .umid: umid,
                .description: sequenceDescription,
                .loudnessIntegrated: loudnessDescription.loudnessIntegrated?.string,
                .loudnessRange: loudnessDescription.loudnessRange?.string,
                .maxTruePeakLevel: loudnessDescription.maxTruePeakLevel?.string,
                .maxMomentaryLoudness: loudnessDescription.maxMomentaryLoudness?.string,
                .maxShortTermLoudness: loudnessDescription.maxShortTermLoudness?.string,
                .codingHistory: codingHistory,
                .version: version > 0 ? version.string : "",
            ]
        }

        set {
            for (key, value) in newValue {
                apply(value, for: key)
            }
        }
    }

    /// Numbers clear on `nil` or empty text and ignore text that doesn't parse; text fields take the value as is.
    private mutating func apply(_ value: String?, for key: Key) {
        guard key.accepts(value) else { return }

        switch key {
        case .version:
            if let unwrapped = value?.int16 {
                version = unwrapped
            }
        case .originator:
            originator = value
        case .originatorReference:
            originatorReference = value
        case .originationDate:
            originationDate = value
        case .originationTime:
            originationTime = value
        case .umid:
            umid = value
        case .description:
            sequenceDescription = value
        case .codingHistory:
            codingHistory = value
        case .loudnessIntegrated:
            loudnessDescription.loudnessIntegrated = value?.double
        case .loudnessRange:
            loudnessDescription.loudnessRange = value?.double
        case .maxTruePeakLevel:
            loudnessDescription.maxTruePeakLevel = value?.float
        case .maxMomentaryLoudness:
            loudnessDescription.maxMomentaryLoudness = value?.double
        case .maxShortTermLoudness:
            loudnessDescription.maxShortTermLoudness = value?.double
        case .timeReferenceSamples:
            timeReference = value?.uInt64
        case .timeReferenceString:
            break // derived from timeReferenceSamples
        }
    }
}

extension BEXTKeyDictionary {
    /// Creates a `BEXTKeyDictionary` from label/value pairs (e.g. from UI row models).
    ///
    /// Labels that match a known ``BEXTDescription/Key/displayName`` are stored
    /// with the corresponding key; unrecognized labels are ignored.
    /// The version key is always set to ``BEXTDescription/defaultVersionString``.
    public init(labels: [(label: String, value: String)]) {
        self.init()
        self[.version] = BEXTDescription.defaultVersionString

        for item in labels {
            guard let key = BEXTDescription.Key(displayName: item.label) else { continue }
            self[key] = item.value
        }
    }
}

// swiftformat:enable consecutiveSpaces

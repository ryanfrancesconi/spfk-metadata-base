import Foundation
import SPFKBase
import SPFKUtils

/// Storage container for audio metadata tags split into two dictionaries:
/// known tags (keyed by ``TagKey``) and custom/unrecognized tags (keyed by raw string).
///
/// Tags that match a known ``TagKey`` are stored in ``tags``; everything else
/// (TXXX user-defined frames, unrecognized INFO tags) goes into ``customTags``.
/// Supports merging multiple `TagData` instances via ``DictionaryMergeScheme``.
public struct TagData: TagPropertiesContainerModel, Hashable, Codable, Sendable {
    /// Prefix that TagLib prepends to duplicate TXXX comment frame keys.
    public static let commentKeyPrefix = "COMMENT:"

    /// Whether both tag dictionaries are empty.
    public var isEmpty: Bool {
        tags.isEmpty && customTags.isEmpty
    }

    /// Standard tags keyed by ``TagKey`` (covers ID3v2, RIFF INFO, and other recognized formats).
    public var tags: TagKeyDictionary

    /// User-defined (TXXX) and unrecognized tags that didn't match any ``TagKey`` case.
    public var customTags: [String: String]

    public init(tags: TagKeyDictionary = .init(), customTags: [String: String] = .init()) {
        self.tags = tags
        self.customTags = customTags
    }

    /// Creates a `TagData` from label/value pairs (e.g. from UI row models).
    ///
    /// Labels that match a known ``TagKey/displayName`` are stored in ``tags``;
    /// everything else goes into ``customTags``.
    public init(labels: [(label: String, value: String)]) {
        var tags = TagKeyDictionary()
        var customTags = [String: String]()

        for item in labels {
            if let tagKey = TagKey(displayName: item.label) {
                tags[tagKey] = item.value
            } else {
                customTags[item.label] = item.value
            }
        }

        self.tags = tags
        self.customTags = customTags
    }

    /// Removes all standard and custom tags.
    public mutating func removeAll() {
        tags.removeAll()
        customTags.removeAll()
    }

    /// Removes all keys present in `data` from this instance's tag dictionaries.
    public mutating func remove(data: TagData) {
        for key in data.tags.keys {
            tags.removeValue(forKey: key)
        }

        for key in data.customTags.keys {
            customTags.removeValue(forKey: key)
        }
    }
}

extension TagData: Serializable {}

extension [TagData] {
    /// Combines multiple `TagData` instances into one using the specified merge scheme.
    ///
    /// - Parameter scheme: `.preserve` keeps existing values, `.replace` overwrites with newer,
    ///   `.combine` concatenates values with a comma separator.
    public func merge(scheme: DictionaryMergeScheme = .preserve) -> TagData {
        let allTags = compactMap(\.tags)
        let allCustomTags = compactMap(\.customTags)

        var mergedTags: TagKeyDictionary = .init()
        var mergedCustomTags: [String: String] = .init()

        for item in allTags {
            mergedTags = mergedTags.merging(
                item,
                uniquingKeysWith: { old, new in
                    switch scheme {
                    case .preserve:
                        old
                    case .replace:
                        new
                    case .combine:
                        old + ", \(new)" // string delimiter ", "
                    }
                })
        }

        for item in allCustomTags {
            mergedCustomTags = mergedCustomTags.merging(
                item,
                uniquingKeysWith: { old, new in
                    switch scheme {
                    case .preserve:
                        old
                    case .replace:
                        new
                    case .combine:
                        old + ", \(new)"
                    }
                })
        }

        return TagData(tags: mergedTags, customTags: mergedCustomTags)
    }
}

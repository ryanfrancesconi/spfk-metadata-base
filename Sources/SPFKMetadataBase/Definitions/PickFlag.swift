// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation

/// A culling decision about one file, independent of its rating. The raw value is what
/// `xmpDM:pick` stores, the property Lightroom Classic reads and writes.
public enum PickFlag: Int, Sendable, Hashable, CaseIterable, Codable {
    case reject = -1
    case none = 0
    case pick = 1
}

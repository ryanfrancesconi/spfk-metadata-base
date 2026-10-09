// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation

/// Which components of a file a description could not read. Such a component holds a default in
/// place of the file's value, so a save refuses to write it.
///
/// A component the file does not have was read: it is absent, not failed. Kept through storage, so
/// a save stays refused until a successful re-read; empty for a description built by hand.
public struct MetadataReadStatus: Hashable, Sendable {
    /// Components whose reader could not open the file.
    public var failed: Set<MetadataComponent> = []

    public init(failed: Set<MetadataComponent> = []) {
        self.failed = failed
    }

    /// Whether the description holds the file's own value for `component`, so a save may write it.
    public func holdsFileValue(of component: MetadataComponent) -> Bool {
        !failed.contains(component)
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation

/// Which components of a file a description could not read. Such a component holds a default in
/// place of the file's value, so a save refuses to write it.
///
/// A component the file does not have was read: it is absent, not failed. Empty for a description
/// that was not parsed, such as one decoded from storage, so nothing is known to have failed.
public struct MetadataReadStatus: Hashable, Sendable {
    /// Components whose reader could not open the file.
    public var failed: Set<MetadataError.Component> = []

    public init(failed: Set<MetadataError.Component> = []) {
        self.failed = failed
    }

    /// Whether the description holds the file's own value for `component`, so a save may write it.
    public func holdsFileValue(of component: MetadataError.Component) -> Bool {
        !failed.contains(component)
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation

/// A file with two independent answers to whether it can be played.
///
/// Both products need the union and neither can use `isAVPlayable` alone, so the derivation lives
/// here rather than being written once per description type. Only the two inputs are required —
/// what sets them differs: ShadowTag asks the codec map about an audio track, TorchTag about a
/// video one.
public protocol MediaFilePlayability {
    /// Whether AVFoundation can open the container.
    var isAVPlayable: Bool { get }

    /// Whether a decoder outside AVFoundation can read this file's essential stream.
    var isDecodable: Bool { get }

    /// Whether the content is DRM-protected (FairPlay). Independent of the other two: AVFoundation
    /// opens such a container and reports it playable, and only a player finds out otherwise.
    var isProtected: Bool { get }
}

public extension MediaFilePlayability {
    /// Whether anything can play this file, which is what a status icon should reflect.
    var isPlayable: Bool {
        (isAVPlayable || isDecodable) && !isProtected
    }
}

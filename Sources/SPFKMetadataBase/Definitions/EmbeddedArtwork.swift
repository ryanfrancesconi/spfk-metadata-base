// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import CoreGraphics
import Foundation
import UniformTypeIdentifiers

/// A file's embedded picture, with the type and labels its container stores beside it.
public struct EmbeddedArtwork: Sendable, Hashable {
    public var cgImage: CGImage

    /// The encoding the picture is stored in. A type ImageIO cannot write, such as WebP, is
    /// written as JPEG.
    public var utType: UTType

    public var pictureDescription: String

    /// The container's picture type name, such as "Front Cover". ID3v2 and FLAC store a name
    /// they do not know as "Other".
    public var pictureType: String

    public init(cgImage: CGImage, utType: UTType, pictureDescription: String = "", pictureType: String = "") {
        self.cgImage = cgImage
        self.utType = utType
        self.pictureDescription = pictureDescription
        self.pictureType = pictureType
    }
}

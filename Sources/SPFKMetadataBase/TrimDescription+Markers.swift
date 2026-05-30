// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi

import Foundation
import SPFKAudioBase
import SPFKBase

extension [TrimDescription] {
    /// Default hex color assigned to auto-detected segment markers.
    public static let segmentMarkerHexColor = HexColor(string: "FF8C00")

    /// Convert an array of detected segments to "In NN" region markers.
    ///
    /// Each `TrimDescription` produces one `.region` `AudioMarkerDescription` named
    /// "In 01", "In 02", etc. (1-based, zero-padded to two digits), with
    /// `startTime = inPoint`, `endTime = outPoint`, and a default orange hex color.
    public func asSegmentMarkers() -> [AudioMarkerDescription] {
        enumerated().map { index, trim in
            AudioMarkerDescription(
                name: String(format: "In %02d", index + 1),
                startTime: trim.inPoint,
                endTime: trim.outPoint,
                hexColor: [TrimDescription].segmentMarkerHexColor,
                markerType: .region
            )
        }
    }
}

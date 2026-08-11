// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import Testing

@testable import SPFKMetadataBase

@Suite
struct SampleRateDescriptionTests {
    /// A whole number of kHz drops its decimal; 44.1 keeps one. Interpolating the rate itself into
    /// a `localized()` key formats it `%lf` instead, which is what put `44.100000` in an alert.
    @Test(arguments: [
        (44100.0, "44.1"),
        (48000.0, "48"),
        (88200.0, "88.2"),
        (96000.0, "96"),
        (192_000.0, "192"),
        (8000.0, "8"),
    ])
    func writesKHzWithoutTrailingZeros(rate: Double, expected: String) {
        #expect(AudioFormatProperties.kHzDescription(for: rate) == expected)
    }
}

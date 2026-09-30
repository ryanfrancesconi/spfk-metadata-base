// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import Testing

@testable import SPFKMetadataBase

struct StrictDecodingTests {
    @Test func aMistypedBEXTFieldFailsTheDecode() {
        let json = Data(#"{"version":2,"originator":5}"#.utf8)
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(BEXTDescription.self, from: json)
        }
    }

    @Test func aMistypedFormatFieldFailsTheDecode() {
        let json = Data(#"{"channelCount":2,"sampleRate":48000,"duration":1,"bitRate":"x"}"#.utf8)
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(AudioFormatProperties.self, from: json)
        }
    }

    @Test func absentOptionalFieldsStillDecode() throws {
        let bext = try JSONDecoder().decode(BEXTDescription.self, from: Data(#"{"version":2}"#.utf8))
        #expect(bext.originator == nil)

        let format = try JSONDecoder().decode(
            AudioFormatProperties.self,
            from: Data(#"{"channelCount":2,"sampleRate":48000,"duration":1}"#.utf8)
        )
        #expect(format.bitRate == nil)
    }
}

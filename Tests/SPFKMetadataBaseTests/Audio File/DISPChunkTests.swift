// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKBase
import SPFKMetadataBase
import Testing

@Suite
struct DISPChunkTests {
    private func payload(format: UInt32, _ body: [UInt8]) -> Data {
        Data([UInt8(format & 0xFF), UInt8(format >> 8 & 0xFF), UInt8(format >> 16 & 0xFF), UInt8(format >> 24)] + body)
    }

    private func text(format: UInt32 = DISPChunk.textFormat, _ body: [UInt8]) -> String? {
        DISPChunk(payload: payload(format: format, body))?.text
    }

    /// The shape BSI Simian's files carry: format 1, ASCII, a NUL, then a pad byte inside the payload.
    @Test func paddedTextStopsAtTheTerminator() {
        let title = "I've Been Everywhere. (Music Sample) SERGIUS"
        #expect(text(Array(title.utf8) + [0, 0]) == title)
    }

    @Test func textWithoutTerminatorRunsToTheEnd() {
        #expect(text(Array("Station ID".utf8)) == "Station ID")
    }

    @Test func trailingLineBreaksAreTrimmedAndInnerOnesKept() {
        #expect(text(Array("Line one\r\nLine two\r\n".utf8) + [0]) == "Line one\r\nLine two")
    }

    @Test func validUTF8IsReadAsUTF8() {
        #expect(text(Array("Café".utf8) + [0]) == "Café")
    }

    @Test func invalidUTF8IsReadAsWindows1252() {
        // 0x93 and 0x94 are curly quotes in 1252 and C1 controls in Latin-1.
        #expect(text([0x93] + Array("Hi".utf8) + [0x94, 0xE9, 0]) == "\u{201C}Hi\u{201D}é")
    }

    @Test func unicodeTextIsUTF16LittleEndian() {
        let units: [UInt8] = "Café ☕".utf16.flatMap { [UInt8($0 & 0xFF), UInt8($0 >> 8)] }
        let body = units + [0, 0, 0x41, 0]
        #expect(text(format: DISPChunk.unicodeTextFormat, body) == "Café ☕")
    }

    @Test func otherFormatsHaveNoText() {
        let chunk = DISPChunk(payload: payload(format: 8, [0x28, 0, 0, 0]))
        #expect(chunk?.formatID == 8)
        #expect(chunk?.text == nil)
    }

    @Test func emptyOrBlankTextIsNone() {
        #expect(text([0]) == nil)
        #expect(text(Array("  \r\n".utf8) + [0]) == nil)
    }

    @Test func aPayloadTooShortForAFormatIDIsInvalid() {
        #expect(DISPChunk(payload: Data([1, 0, 0])) == nil)
    }

    @Test func displayTextIsTheFirstChunkWithText() {
        let chunks = [
            payload(format: 8, [0x28, 0, 0, 0]),
            payload(format: DISPChunk.textFormat, Array("First".utf8) + [0]),
            payload(format: DISPChunk.textFormat, Array("Second".utf8) + [0]),
        ].compactMap(DISPChunk.init(payload:))

        #expect(DISPChunk.displayText(in: chunks) == "First")
        #expect(DISPChunk.displayText(in: []) == nil)
    }
}

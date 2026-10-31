// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation

/// A RIFF `DISP` chunk: a 32-bit little-endian Windows clipboard format ID, then data in that
/// format. A file may hold several, one per format, in order of preference.
public struct DISPChunk: Hashable, Sendable {
    public static let textFormat: UInt32 = 1
    public static let unicodeTextFormat: UInt32 = 13

    public let formatID: UInt32
    public let data: Data

    /// Nil for a payload too short to hold a format ID.
    public init?(payload: Data) {
        let bytes = [UInt8](payload)
        guard bytes.count >= 4 else { return nil }

        formatID = UInt32(bytes[0]) | UInt32(bytes[1]) << 8 | UInt32(bytes[2]) << 16 | UInt32(bytes[3]) << 24
        data = Data(bytes[4...])
    }

    /// The text of a `CF_TEXT` or `CF_UNICODETEXT` chunk up to its terminator, trailing whitespace
    /// trimmed; nil for any other format or no text. `CF_TEXT` is the writer's ANSI code page,
    /// read as UTF-8 when valid and as Windows-1252 otherwise.
    public var text: String? {
        let bytes = [UInt8](data)
        let decoded: String?

        switch formatID {
        case Self.textFormat:
            let text = Data(bytes.prefix { $0 != 0 })
            decoded = String(data: text, encoding: .utf8)
                ?? String(data: text, encoding: .windowsCP1252)
                ?? String(data: text, encoding: .isoLatin1)

        case Self.unicodeTextFormat:
            var units: [UInt8] = []
            var i = 0
            while i + 1 < bytes.count, bytes[i] != 0 || bytes[i + 1] != 0 {
                units += [bytes[i], bytes[i + 1]]
                i += 2
            }
            decoded = String(data: Data(units), encoding: .utf16LittleEndian)

        default:
            decoded = nil
        }

        guard let trimmed = decoded?.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression),
              !trimmed.isEmpty else { return nil }

        return trimmed
    }
}

extension DISPChunk {
    /// The text of the first chunk that has one, the spec's order of preference being file order.
    public static func displayText(in chunks: [DISPChunk]) -> String? {
        chunks.lazy.compactMap(\.text).first
    }
}

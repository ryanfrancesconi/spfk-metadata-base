// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

import Foundation
import SPFKBase
import Testing

@testable import SPFKMetadataBase

@Suite
struct RIFFInfoFieldsTests {
    @Test func aCustomTagNamesItsFieldByIDInAnyCaseOrByTagLibName() {
        #expect(RIFFInfoFields.customTag("BCPR", names: "BCPR"))
        #expect(RIFFInfoFields.customTag("bcpr", names: "BCPR"))
        #expect(RIFFInfoFields.customTag("ITRK", names: "itrk"))
        #expect(RIFFInfoFields.customTag("SOURCEFORM", names: "ISRF"))
        #expect(!RIFFInfoFields.customTag("SOURCEFORM", names: "BCPR"))
        #expect(!RIFFInfoFields.customTag("ISRF", names: "BCPR"))
    }

    @Test func onlyAnIDWithoutLowercaseIsEditable() {
        #expect(RIFFInfoFields.isEditable(id: "BCPR"))
        #expect(RIFFInfoFields.isEditable(id: "BWF1"))
        #expect(!RIFFInfoFields.isEditable(id: "itrk"))
        #expect(!RIFFInfoFields.isEditable(id: "ICoM"))
    }

    @Test func aNamedFrameShowsItsSpecNameAndAnyOtherIDItself() {
        #expect(RIFFInfoFields.displayName(for: "ISRF") == "Source Form")
        #expect(RIFFInfoFields.displayName(for: "BCPR") == "BCPR")
    }

    @Test func differenceListsChangedAddedAndRemovedFields() {
        let onDisk = RIFFInfoFields(fields: ["BCPR": "Old", "BETM": "02:00", "ICOM": "Same"])
        let edited = RIFFInfoFields(fields: ["BCPR": "New", "ICOM": "Same", "ISRF": "1100"], infoTitle: "Ignored")

        let changes = edited.difference(from: onDisk)

        #expect(changes == [
            TagValueChange(name: "INFO: BCPR", before: "Old", after: "New"),
            TagValueChange(name: "INFO: BETM", before: "02:00", after: ""),
            TagValueChange(name: "INFO: Source Form", before: "", after: "1100"),
        ])
    }

    @Test func setFieldDropsControlCharacters() {
        var fields = RIFFInfoFields()
        fields.set(field: "BCPR", value: "A\u{01}B\tC")
        #expect(fields.fields["BCPR"] == "AB\tC")
    }

    @Test func aDescriptionKeepsUnreadApartFromEmptyThroughCodable() throws {
        let url = URL(fileURLWithPath: "/tmp/take.wav")

        for fields in [nil, RIFFInfoFields(), RIFFInfoFields(fields: ["itrk": "1", "ITRK": "2"], displayText: "D")] {
            var description = MetaAudioFileDescription(url: url)
            description.riffInfoFields = fields

            let decoded = try JSONDecoder().decode(MetaAudioFileDescription.self, from: JSONEncoder().encode(description))
            #expect(decoded.riffInfoFields == fields)
        }
    }

    @Test func aFieldEditIsAMetadataChangeAndTheReadOnlyValuesAreNot() {
        var base = MetaAudioFileDescription(url: URL(fileURLWithPath: "/tmp/take.wav"))
        base.riffInfoFields = RIFFInfoFields(fields: ["BCPR": "Old"])

        var edited = base
        edited.riffInfoFields?.fields["BCPR"] = "New"
        #expect(edited.hasMetadataChanges(from: base))

        var display = base
        display.riffInfoFields?.displayText = "MotionPulse"
        display.riffInfoFields?.infoTitle = "Old Title"
        #expect(!display.hasMetadataChanges(from: base))
    }
}

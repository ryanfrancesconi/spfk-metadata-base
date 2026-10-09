// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-metadata-base

@preconcurrency import AEXML
import Foundation
import SPFKAudioBase
import SPFKBase

extension IXMLMetadata {
    /// ``document`` with the modeled properties applied: nil and empty values remove their element,
    /// and elements the type does not model are kept in place. LOUDNESS is kept as read unless
    /// ``loudnessDescription`` changed; a changed one is rebuilt from the model, to two decimal
    /// places and without the element's unmodeled children.
    ///
    /// The text parsed by ``init(xml:)``, comments and CDATA included, while the result would not
    /// differ from it; any edit re-serializes the whole document, which drops both.
    public var xml: String {
        let rendered = rendered

        if let parsedText, rendered == document.xml {
            return parsedText
        }

        return rendered
    }

    /// Whether two chunks hold the same document once parsed. Text that does not parse is compared
    /// as is; nil and empty are the same absent chunk.
    public static func isSameDocument(_ lhs: String?, _ rhs: String?) -> Bool {
        let lhs = lhs?.isEmpty == true ? nil : lhs
        let rhs = rhs?.isEmpty == true ? nil : rhs

        guard lhs != rhs else { return true }
        guard let lhs, let rhs,
              let left = try? document(xml: lhs), let right = try? document(xml: rhs)
        else { return false }

        return left.xml == right.xml
    }

    /// ``document`` with the modeled properties applied, serialized.
    var rendered: String {
        let (doc, root) = editableCopy()

        set(root, .ixmlVersion, version)
        set(root, .project, project)
        set(root, .scene, scene)
        set(root, .take, take)
        set(root, .tape, tape)
        set(root, .familyUID, familyUID)
        set(root, .familyName, familyName)
        set(root, .fileUID, fileUID)
        set(root, .note, note)
        set(root, .circled, circled)
        set(root, .wildTrack, wildTrack)

        update(container: .speed, in: root) { speed in
            set(speed, .masterSpeed, masterSpeed)
            set(speed, .currentSpeed, currentSpeed)
            set(speed, .timecodeRate, timecodeRate)
            set(speed, .timecodeFlag, timecodeFlag)
            set(speed, .fileSampleRate, fileSampleRate)
            set(speed, .audioBitDepth, audioBitDepth)
            set(speed, .digitizerSampleRate, digitizerSampleRate)
            set(speed, .timestampSamplesSinceMidnightHi, timestampSamplesSinceMidnightHi)
            set(speed, .timestampSamplesSinceMidnightLo, timestampSamplesSinceMidnightLo)
            set(speed, .timestampSampleRate, timestampSampleRate)
        }

        updateTrackList(in: root)

        let readLoudness = root[.loudness].flatMap { parseLoudness(element: $0) }
        if readLoudness != loudnessDescription {
            replace(.loudness, in: root, with: loudnessElement())
        }

        update(container: .bext, in: root) { bext in
            set(bext, .bextVersion, bextVersion)
            set(bext, .bextDescription, bextDescriptionText)
            set(bext, .bextOriginator, bextOriginator)
            set(bext, .bextOriginatorReference, bextOriginatorReference)
            set(bext, .bextOriginationDate, bextOriginationDate)
            set(bext, .bextOriginationTime, bextOriginationTime)
            set(bext, .bextTimeReferenceLow, bextTimeReferenceLow)
            set(bext, .bextTimeReferenceHigh, bextTimeReferenceHigh)
            set(bext, .bextCodingHistory, bextCodingHistory)
            set(bext, .bextUMID, bextUMID)
        }

        update(container: .history, in: root) { history in
            set(history, .originalFilename, originalFilename)
            set(history, .parentFilename, parentFilename)
            set(history, .parentUID, parentUID)
        }

        updateRaw(.user, in: root, userContent)
        updateRaw(.steinberg, in: root, steinbergContent)
        updateRaw(.aswg, in: root, aswgContent)

        update(container: .location, in: root) { loc in
            set(loc, .locationGPS, locationGPS)
            set(loc, .locationAltitude, locationAltitude)
            set(loc, .locationTime, locationTime)
        }

        return doc.xml
    }

    /// A private copy of ``document`` and its BWFXML element; a fresh document when it has none.
    private func editableCopy() -> (AEXMLDocument, AEXMLElement) {
        if let copy = try? Self.document(xml: document.xml),
           let root = copy.root[.bwfxml] ?? nonErrorRoot(copy)
        {
            return (copy, root)
        }

        let doc = AEXMLDocument()
        return (doc, doc.addChild(name: IXMLElement.bwfxml.rawValue))
    }

    private func set(_ parent: AEXMLElement, _ key: IXMLElement, _ value: String?) {
        let existing = parent.children.filter { $0.name == key.rawValue }

        guard let value, !value.isEmpty else {
            existing.forEach { $0.removeFromParent() }
            return
        }

        if let first = existing.first {
            first.value = value
        } else {
            parent.addChild(name: key.rawValue, value: value)
        }
    }

    /// Creates the container when absent and removes it when the update leaves it empty.
    private func update(container key: IXMLElement, in root: AEXMLElement, _ body: (AEXMLElement) -> Void) {
        let element = root[key] ?? root.addChild(name: key.rawValue)
        body(element)

        if element.children.isEmpty {
            element.removeFromParent()
        }
    }

    /// Tracks map onto the existing TRACK elements by position, so a track's unmodeled children stay with it.
    private func updateTrackList(in root: AEXMLElement) {
        guard let tracks, tracks.isNotEmpty else {
            root[.trackList]?.removeFromParent()
            return
        }

        let trackList = root[.trackList] ?? root.addChild(name: IXMLElement.trackList.rawValue)
        set(trackList, .trackCount, "\(tracks.count)")

        var elements = trackList.children.filter { $0.name == IXMLElement.track.rawValue }

        while elements.count > tracks.count {
            elements.removeLast().removeFromParent()
        }

        while elements.count < tracks.count {
            elements.append(trackList.addChild(name: IXMLElement.track.rawValue))
        }

        for (track, element) in zip(tracks, elements) {
            set(element, .channelIndex, track.channelIndex)
            set(element, .interleaveIndex, track.interleaveIndex)
            set(element, .name, track.name)
            set(element, .function, track.function)
        }
    }

    private func loudnessElement() -> AEXMLElement? {
        guard let loudness = loudnessDescription, loudness.isValid else { return nil }

        let element = AEXMLElement(name: IXMLElement.loudness.rawValue)
        addIfPresent(to: element, .loudnessValue, loudness.loudnessIntegrated)
        addIfPresent(to: element, .loudnessRange, loudness.loudnessRange)
        addIfPresent(to: element, .maxTruePeakLevel, loudness.maxTruePeakLevel.map(Double.init))
        addIfPresent(to: element, .maxMomentary, loudness.maxMomentaryLoudness)
        addIfPresent(to: element, .maxShortTerm, loudness.maxShortTermLoudness)
        return element
    }

    /// A container held as raw XML. Content that does not parse leaves the existing element as it is.
    private func updateRaw(_ key: IXMLElement, in root: AEXMLElement, _ content: String?) {
        guard let content else {
            // `init(document:)` leaves the content nil for a childless container.
            if let existing = root[key], existing.children.isNotEmpty {
                existing.removeFromParent()
            }
            return
        }

        guard let parsed = try? Self.document(xml: content) else { return }
        replace(key, in: root, with: parsed.root)
    }

    /// Swaps `key`'s contents for `replacement`'s, keeping its position; nil removes it.
    private func replace(_ key: IXMLElement, in root: AEXMLElement, with replacement: AEXMLElement?) {
        guard let replacement else {
            root[key]?.removeFromParent()
            return
        }

        guard let existing = root[key] else {
            root.addChild(replacement)
            return
        }

        existing.name = replacement.name
        existing.value = replacement.value
        existing.attributes = replacement.attributes
        existing.children.forEach { $0.removeFromParent() }
        replacement.children.forEach { existing.addChild($0) }
    }

    /// Two decimal places.
    private func addIfPresent(to parent: AEXMLElement, _ key: IXMLElement, _ value: Double?) {
        guard let value else { return }
        parent.addChild(name: key.rawValue, value: String(format: "%.2f", value))
    }
}

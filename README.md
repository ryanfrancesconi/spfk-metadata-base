# SPFKMetadataBase

[![Version](https://img.shields.io/github/v/tag/ryanfrancesconi/spfk-metadata-base)](https://github.com/ryanfrancesconi/spfk-metadata-base/tags)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-metadata-base%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanfrancesconi/spfk-metadata-base)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-metadata-base%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanfrancesconi/spfk-metadata-base)

Pure Swift audio metadata data types extracted from [SPFKMetadata](https://github.com/ryanfrancesconi/spfk-metadata). No C++, TagLib, or libsndfile dependency — suitable for lightweight consumers that need metadata type definitions without file I/O.

For reading and writing files, use [SPFKMetadata](https://github.com/ryanfrancesconi/spfk-metadata), which depends on this package and re-exports it.

## Requirements

- **Platforms:** macOS 13+, iOS 16+
- **Swift:** 6.2+

## Types

### Tag Properties

| Type | Description |
|------|-------------|
| **TagKey** | Case enum — canonical key type mapping to ID3 frames and RIFF INFO tags |
| **TagProperties** | Struct wrapping `TagData` with `tagLibPropertyMap` for bridge interop |
| **TagPropertiesAV** | AVFoundation-based tag reader (read-only) |
| **AVMetadataProbe** / **AVMetadataProbeItem** | Every metadata keyspace and item a file declares, as AVFoundation reports them, before mapping to `TagKey` |
| **TagData** | Container with `TagKeyDictionary` and custom tags, with merge support |
| **TagGroup** | Enum grouping TagKeys into logical sets (common, music, loudness, etc.) |
| **ID3FrameKey** | Case enum for ID3v2.4 frame identifiers |
| **InfoFrameKey** | Case enum for RIFF INFO chunk tags |
| **TagFrameKey** | Protocol shared by both frame key types |
| **TagValueChange** | One tag value that differs between two `TagData`. An absent key is carried as `""` rather than `nil`, so an added and a cleared value are both ordinary changes with one side empty |
| **TagValueConstraint** | How a tag value string is validated and clamped |

### Audio File Definitions

| Type | Description |
|------|-------------|
| **MetaAudioFileDescription** | Top-level Codable struct aggregating tags, audio format, BEXT, iXML, markers, artwork, XMP, and the video track, audio tracks and QuickTime user data |
| **AudioFormatProperties** | Channel count, sample rate, bit depth, bit rate, and duration |
| **BEXTDescription** | Broadcast Wave Extension (BWF) chunk wrapper (v0/v1/v2) |
| **BEXTDescription.Key** | Enum of BEXT field keys with dictionary-style subscript access |
| **ImageDescription** | Embedded artwork container with CGImage and Codable conformance; keeps the bytes the file stored while the image is unchanged, so a save writes them back as they were |
| **EmbeddedArtwork** | A file's picture with its stored type, description and picture type |
| **WaveFileProperties** | A WAV's format and BEXT chunk, without its tags, markers or artwork |
| **MetadataError** | A metadata read or write that failed, naming the operation and the component |
| **UnstorableMetadataError** | A save asked for something the file's container has no writer for |
| **TagPropertiesContainerModel** | Protocol for types that contain tag properties |
| **MediaFilePlayability** | Whether a file can be played, and by which of the two paths |
| **MetadataDirtyFlag** | Which parts of a description have unsaved edits |
| **StartTimecodeResolution** / **StartTimecodeSource** | A start timecode together with the carrier it came from |

#### MediaFilePlayability

Playability is two questions, not one, because the answers diverge for Matroska: whether
AVFoundation can open the file, and whether a demuxer and decoder can. A file is playable if either
is true and it is not DRM-protected (`isProtected`): AVFoundation opens a FairPlay container and
reports it playable, so protection is a separate input.

**Neither is derivable from the path extension.** A `.mkv` whose audio codec has no decoder is not
playable despite being a Matroska file, and a `.mov` AVFoundation refuses is not playable despite
being a native container — so both are measured from the file rather than inferred from its name.
A UI showing a "cannot play" state reads `isPlayable`; a caller choosing between `FilePlayer` and
`StreamPlayer` reads `isAVPlayable`.

### iXML (BWFXML)

The [iXML](http://www.ixml.info) model. `IXMLMetadata.xml` writes the modeled fields and the raw USER, ASWG and STEINBERG containers back into a copy of the parsed document: a nil or empty value removes its element, and elements the model does not cover are kept in place. LOUDNESS is kept as read unless `loudnessDescription` changed, in which case it is rebuilt from the model. A document no modeled value changed comes back as the text `init(xml:)` parsed, comments and CDATA included; an edit re-serializes it, which drops both. `IXMLMetadata.isSameDocument(_:_:)` compares two chunks' text once parsed.

| Type | Description |
|------|-------------|
| **IXMLMetadata** | The document: production, speed, track list, loudness, BEXT mirror, history, user, ASWG and location. `init(xml:)` parses, `.xml` serializes |
| **IXMLTagDescriptor** | One field for a generic editor: display name, section, XML tag, read-only status and edit style; the registry of every field |
| **IXMLSection** | The sections a descriptor belongs to |
| **IXMLElement** | Element names, with an `AEXMLElement` subscript for child access |
| **IXMLUserFields** | The Soundminer USER container, keeping fields it does not model |
| **UCSUserFields** | UCS category, subcategory and CatID from the USER container |
| **IXMLASWGFields** | The ASWG container |

### Markers

| Type | Description |
|------|-------------|
| **AudioMarkerDescription** | Format-agnostic marker struct with name, start/end time, color, and markerID |
| **AudioMarkerDescriptionCollection** | Ordered collection with insert, remove, update, sort, and automatic ID assignment |
| **AudioMarkerType** | Structural classification of a marker |

## Installation

```swift
.package(url: "https://github.com/ryanfrancesconi/spfk-metadata-base", from: "1.18.0")
```

```swift
import SPFKMetadataBase
```

## Dependencies

| Package | Description |
|---------|-------------|
| [spfk-audio-base](https://github.com/ryanfrancesconi/spfk-audio-base) | Shared audio type definitions |
| [AEXML](https://github.com/tadija/AEXML) | XML parsing and writing for the iXML model |
| [spfk-image](https://github.com/ryanfrancesconi/spfk-image) | Artwork thumbnail decoding, resizing and PNG encoding |
| [spfk-utils](https://github.com/ryanfrancesconi/spfk-utils) | Foundation utilities and extensions |
| [spfk-video](https://github.com/ryanfrancesconi/spfk-video) | `VideoTrackProperties` on a media description |
| [swift-timecode](https://github.com/orchetect/swift-timecode) | Timecode parsing and formatting |

## About

Spongefork is the personal software projects of musician and developer [Ryan Francesconi](https://spongefork.com). Dedicated to creative sound manipulation, his first application, Spongefork, was released in 1999 for macOS 8. From 2026, Spongefork returns as his software container for more musical experimentation. In addition to [software releases](https://spongefork.com/shadowtag/), open source components can be found on his [GitHub page](https://github.com/ryanfrancesconi).

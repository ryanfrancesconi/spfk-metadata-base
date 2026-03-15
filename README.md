# SPFKMetadataBase

Pure Swift audio metadata data types extracted from [SPFKMetadata](https://github.com/ryanfrancesconi/spfk-metadata). No C++, TagLib, or libsndfile dependency — suitable for lightweight consumers that need metadata type definitions without file I/O.

For file reading/writing, marker parsing, and BEXT I/O, use [SPFKMetadata](https://github.com/ryanfrancesconi/spfk-metadata) which depends on this package and adds I/O capabilities.

## Requirements

- **Platforms:** macOS 13+, iOS 16+
- **Swift:** 6.2+

## Types

### Tag Properties

| Type | Description |
|------|-------------|
| **TagKey** | 100+ case enum — canonical key type mapping to ID3 frames and RIFF INFO tags |
| **TagProperties** | Struct wrapping `TagData` with `tagLibPropertyMap` for bridge interop |
| **TagPropertiesAV** | AVFoundation-based tag reader (read-only) |
| **TagData** | Container with `TagKeyDictionary` and custom tags, with merge support |
| **TagSet** | Enum grouping TagKeys into logical sets (common, music, loudness, etc.) |
| **ID3FrameKey** | 80+ case enum for ID3v2.4 frame identifiers |
| **InfoFrameKey** | 90+ case enum for RIFF INFO chunk tags |
| **TagFrameKey** | Protocol shared by both frame key types |

### Audio File Definitions

| Type | Description |
|------|-------------|
| **MetaAudioFileDescription** | Top-level Codable struct aggregating tags, audio format, BEXT, iXML, markers, and artwork |
| **AudioFormatProperties** | Channel count, sample rate, bit depth, bit rate, and duration |
| **BEXTDescription** | Broadcast Wave Extension (BWF) chunk wrapper (v0/v1/v2) |
| **BEXTDescription.Key** | Enum of BEXT field keys with dictionary-style subscript access |
| **ImageDescription** | Embedded artwork container with CGImage and Codable conformance |
| **TagPropertiesContainerModel** | Protocol for types that contain tag properties |

### Markers

| Type | Description |
|------|-------------|
| **AudioMarkerDescription** | Format-agnostic marker struct with name, start/end time, color, and markerID |
| **AudioMarkerDescriptionCollection** | Ordered collection with insert, remove, update, sort, and automatic ID assignment |

## Installation

```swift
.package(url: "https://github.com/ryanfrancesconi/spfk-metadata-base", from: "0.0.1")
```

```swift
import SPFKMetadataBase
```

## Dependencies

| Package | Description |
|---------|-------------|
| [spfk-audio-base](https://github.com/ryanfrancesconi/spfk-audio-base) | Shared audio type definitions |
| [spfk-utils](https://github.com/ryanfrancesconi/spfk-utils) | Foundation utilities and extensions |

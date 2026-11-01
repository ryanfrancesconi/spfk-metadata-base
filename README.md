# SPFKMetadataBase

[![Version](https://img.shields.io/github/v/tag/ryanfrancesconi/spfk-metadata-base)](https://github.com/ryanfrancesconi/spfk-metadata-base/tags)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-metadata-base%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanfrancesconi/spfk-metadata-base)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-metadata-base%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanfrancesconi/spfk-metadata-base)

The metadata vocabulary under [spfk-metadata](https://github.com/ryanfrancesconi/spfk-metadata): tag
keys and values, the audio file description, BEXT, iXML, markers, artwork, and the errors and dirty
flags a save reports. It is support code that other packages build on, not something an app uses on
its own.

It holds no TagLib, C++ or file-writing code, so a package that only needs to name or carry metadata
can depend on it without taking on a container library. Reading and writing files belongs to
spfk-metadata, which depends on this package and re-exports it; XMP belongs to spfk-metadata-xmp and
spfk-metadata-image.

## Playability is measured, not inferred

`MediaFilePlayability` answers two questions, whether AVFoundation can open a file and whether a
demuxer and decoder can, because the answers diverge for Matroska. Neither follows from the path
extension, and a FairPlay-protected file reports playable to AVFoundation, so protection is a
separate input.

## About

Spongefork is the personal software projects of musician and developer [Ryan Francesconi](https://spongefork.com). Dedicated to creative sound manipulation, his first application, Spongefork, was released in 1999 for macOS 8. From 2026, Spongefork returns as his software container for more musical experimentation. In addition to [software releases](https://spongefork.com/shadowtag/), open source components can be found on his [GitHub page](https://github.com/ryanfrancesconi).

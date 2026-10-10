# @noflo/adapters

Data adaptors for [NoFlo](http://noflojs.org/)

This package provides components for converting between NoFlo packet
stream structures and JavaScript data structures: objects to bracketed
streams and back, arrays, pairs, and property transposition.

## Usage

Install the package:

    npm install @noflo/adapters

The components are then available under the `adapters/` namespace, for
example `adapters/ObjectToPackets` or `adapters/PacketsToObject`.

Components include:

- `ObjectToPackets` — expand an object into a bracketed stream
- `PacketsToObject` — collapse a bracketed stream into an object
- `PacketsToArray` — merge a stream into an array
- `PairsToObject` — pair odd/even packets into an object
- `ObjectToString`, `PropertiesToObjects` — data shaping

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## [2.0.0-alpha.1] - 2026-10-09

### Added

- The package is renamed to `@noflo/adapters`; graph component identifiers are unaffected and keep resolving under the `adapters/` namespace

### Changed

- All 6 components are converted from CoffeeScript to modern JavaScript ES modules for NoFlo 2.x (esm-only), with TypeScript-checked sources and Biome formatting
- Components follow the 2.x Process API contract: preconditions are checked with `has`/`hasData`/`hasStream` before any `get`/`getData` call
- `ObjectToPackets` uses the built-in `structuredClone` instead of the `owl-deepcopy` package, and the `underscore` dependency is dropped (language built-ins)
- Components that used the 1.x bare-value `sendDone(value)` shorthand now send on their named output port explicitly

### Fixed

- Test suite rebuilt on `node:test` (12 tests) covering all 6 components, replacing the Mocha CoffeeScript suite

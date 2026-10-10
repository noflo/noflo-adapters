# Migration notes: noflo-adapters → @noflo/adapters

Migrated 2026-10-09. 6 components, all converted from CoffeeScript to
JavaScript ES modules.

## Scope

- All 6 components converted; 12 `node:test` tests cover all of them.
  No fbp-spec cases: the behaviors are stream-structure transformations
  better served by direct tests.
- `owl-deepcopy` dropped (built-in `structuredClone`); `underscore`
  dropped (language built-ins).

## 2.x compatibility findings

- **Bare-value `sendDone(value)` shorthand removed.** `PacketsToObject`
  and `PacketsToArray` sent bare values in 1.x; the 2.x components send
  on the named `out` port explicitly.
- **Unbracketed data IPs are complete streams.** `PairsToObject`
  receives key/value pairs as consecutive data IPs; under 2.x each
  unbracketed data IP is its own complete stream, so callers must send
  the pairs inside a bracket (or accept one empty object per packet).
  The 1.x disconnect-delimited stream had the same requirement in
  practice; the tests send a bracketed stream.
- **`PacketsToArray` nested-bracket jank preserved.** The 1.x
  implementation resets its working buffer on every openBracket after
  data has accumulated and pushes on every closeBracket, so interleaved
  data/nested-bracket streams produce quirky shapes. The port is
  source-faithful; the tests cover the shapes the 1.x spec exercised
  (bracketed stream, single IP).
- **`PacketsToObject.objectify` numeric keys.** The 1.x `_.isNumber`
  check tests the key TYPE, and `Object.keys` yields strings — so all
  own keys (including numeric-string ones like `'0'`) are kept when
  rebuilding array-mixed objects. The port preserves this, matching the
  1.x expectation `{'0': 'a', b: [...]}`.

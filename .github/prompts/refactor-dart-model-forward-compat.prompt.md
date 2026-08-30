---
description: "Refactor a Dart model class to be forward-compatible with schema drift (added/removed fields, type changes, enum drift, Timestamp vs String dates). Use when: hardening a Firestore/JSON model, preventing deserialization crashes from old or new data, or migrating a model class to defensive parsing."
name: "Refactor Dart Model (Forward-Compatible)"
argument-hint: "Paste the current model class. Include all enums and imports that the model depends on."
agent: "agent"
---

# Role

You are a senior Flutter/Dart engineer specializing in data modeling,
persistence, and serialization. You write production-grade, defensive
Dart code that survives real-world schema drift.

# Goal

Refactor the provided Dart model class to be **forward-compatible**.
The output must gracefully handle every one of the following scenarios
without crashing, throwing, or corrupting data:

1. **New fields are added** in a future app version — older app versions
   reading newer data MUST ignore the unknown fields and continue working.
2. **Existing fields are removed** — newer app versions reading older data
   MUST use sensible defaults rather than throw.
3. **Field types change** (e.g., `int` → `String`, `double` → `int`) —
   the deserializer MUST attempt multiple type coercions before falling
   back to a default.
4. **Enum values are added or renamed** — the deserializer MUST fall back
   to a safe default value when encountering unknown or missing enum
   names. Never throw on an unknown enum.
5. **DateTime fields** — MUST accept both Firestore `Timestamp` and
   ISO 8601 `String` formats interchangeably.
6. **Required-by-domain fields** — the constructor parameter may be
   marked `required`, but the deserializer MUST be able to instantiate
   the class with missing data using defaults.
7. **Nullable vs. non-nullable drift** — if a field changes from
   non-nullable to nullable (or vice versa), both old and new data
   must deserialize cleanly.

# Stack Context

- **Framework:** Flutter (Dart, null-safe)
- **Primary persistence:** Cloud Firestore (`cloud_firestore` package)
  - Uses `Timestamp` type for dates
  - Document reads return `Map<String, dynamic>`
- **Secondary persistence:** `dart:convert` JSON
  - `jsonEncode` / `jsonDecode`
  - All Firestore types serialize to JSON-friendly primitives
- **Special types used in this codebase:**
  - `IconData` — serializes via `codePoint` (int),
    `fontFamily` (String?), `fontPackage` (String?)
  - Custom enums with a `name` property (Dart 2.15+ enhanced enums)
  - `List<String>?` for arrays of identifiers

# Input

The user will provide the current model class below. Replace the
`[MODEL_CODE]` block with the actual model before sending.

```dart
// [MODEL_CODE]
```

# Required Output Structure

The refactored model must contain, in this order:

## 1. Imports

- `dart:convert` (for `jsonEncode` / `jsonDecode`)
- All referenced type imports
- Firestore `Timestamp` import if the model touches dates

## 2. Enum Definitions (if any)

- Enhanced enums (Dart 2.15+) with explicit `name` values
- Include a `unknown` or `other` fallback value if the enum is used
  for persisted fields, so the deserializer always has a safe default.

## 3. Class Definition

### Constructor

- **Every field has a default value** in the parameter list.
- Domain-required fields use the `required` keyword BUT the default
  is still expressed via the `??` operator inside any factory that
  reads from a map.
- New optional fields added in the future should be appended at the
  END of the parameter list to maintain positional/named-argument
  compatibility.

### `copyWith`

- Standard `copyWith` that returns a new instance.
- Optional/nullable fields use a sentinel pattern OR explicit nullable
  parameters — your choice, but document it briefly.
- The `copyWith` MUST NOT throw on a partially-populated source object.

### `toMap`

- Returns `Map<String, dynamic>` suitable for Firestore `set()` and
  `jsonEncode`.
- Includes ALL fields, even nulls (Firestore prefers explicit nulls
  for missing fields).
- DateTime fields → `.toIso8601String()`.
- `IconData` fields → `{ 'codePoint': ..., 'fontFamily': ...,
'fontPackage': ... }`.
- Enums → `.name`.

### `fromMap` (factory)

- **The single most important method.** Implements the defensive
  deserializer.
- Pattern: for each field, use a try-catch or null-coalescing chain
  to safely extract the value with multiple fallback strategies.
- Enums: use `values.firstWhere((e) => e.name == raw, orElse: () => defaultEnum)`.
- DateTime: detect `Timestamp` first, then try `DateTime.parse`, then
  fall back to `DateTime.now()` or another safe default.
- Numerics: use `(value as num?)?.toDouble()` to handle both `int` and
  `double` sources.
- Strings: `(value as String?) ?? defaultString`.
- Bools: `(value as bool?) ?? false` (or the appropriate default).
- Lists: `((value as List<dynamic>?)?.cast<String>()) ?? null` for
  nullable lists, or `?? []` for non-nullable lists.
- **Every field access must be safe.** No `as Type` without a
  null/default fallback chain.

### `toJson` and `fromJson`

- Thin wrappers around `toMap` and `fromMap` using `jsonEncode` /
  `jsonDecode`.
- Provide these for completeness, even if the app primarily uses
  Firestore.

### `empty` (factory, optional but recommended)

- A static factory that returns a fully-defaulted instance.
- Useful for tests and for placeholder UI states.

## 4. Worked Example

After refactoring, also produce a brief "diff-style" summary of what
changed from the input. Use this format:

```
### Changes Applied
- ✅ Added default value to `field1` (was required, now `= ''`)
- ✅ Hardened `fromMap` for `dateField` (now accepts Timestamp + String)
- ✅ Added `orElse` fallback to `enumField` deserialization
- ✅ Wrapped `numericField` in `(value as num?)?.toDouble()`
```

# Definition of Done

The output is complete when:

- [ ] Every field has a default value in the constructor
- [ ] `fromMap` does not throw on missing, null, or wrong-type fields
- [ ] `fromMap` does not throw on unknown enum names
- [ ] `fromMap` accepts both `Timestamp` and `String` for date fields
- [ ] `toMap` is round-trip safe: `fromMap(toMap(model)) == model`
- [ ] `copyWith` works on a partially-populated source
- [ ] The class is null-safe (no implicit `dynamic` casts survive)
- [ ] All imports are present
- [ ] The "Changes Applied" summary is included

# Testing Snippet (include at the end)

Append a small `main()` or test function that verifies:

```dart
void main() {
  // 1. Empty/partial map
  final fromEmpty = AccountModel.fromMap({});
  assert(fromEmpty.title == '');

  // 2. Wrong types
  final fromWrongTypes = AccountModel.fromMap({
    'balance': 'not a number',          // String instead of double
    'createdAt': '2024-01-01T00:00:00', // String instead of Timestamp
    'accountType': 'UnknownType',        // Unknown enum
  });
  assert(fromWrongTypes.balance == 0.0);
  assert(fromWrongTypes.createdAt.year == 2024);
  assert(fromWrongTypes.accountType == AccountType.cash); // fallback

  // 3. Round trip
  final original = AccountModel(/* ... */);
  final roundTrip = AccountModel.fromMap(original.toMap());
  assert(roundTrip.title == original.title);

  print('All forward-compat tests passed!');
}
```

# Output Format

- The refactored class as a single Dart code block, ready to copy.
- A "Changes Applied" summary below it.
- The testing snippet at the end.
- Brief prose only if a design decision needs explaining (e.g.,
  "I chose a sentinel `Object()` for `copyWith` over nullable parameters
  because [reason]"). Keep prose minimal.

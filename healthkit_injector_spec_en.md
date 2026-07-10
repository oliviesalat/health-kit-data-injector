# Spec: HealthKit Data Injector (test iOS app)

## Goal

Build a simple standalone iOS app (SwiftUI, separate Xcode project) for **manually inserting test data into HealthKit via the iOS Simulator**. This app is needed to test HealthKit SDK read pipelines — some data types (e.g. `contraceptive`, `hypertensionEvent`) cannot be entered through the stock Health app, since it has no manual-entry UI for these types.

## Context

- Development is done on macOS, Xcode 26.3, testing on iOS Simulator.
- This app is a standalone helper tool using the HealthKit framework directly.

## Functional Requirements

### 1. HealthKit Authorization
- On launch, the app must request write access (`HKHealthStore.requestAuthorization`) for **all types in the list below** (see section 3) at once.
- Handle the case of denied access — show an alert.

### 2. Data Types List Screen
- A list (List/Form) of all supported data types (see section 3).
- Each row must contain:
  - Type name (human-readable + technical identifier)
  - An input field/picker for the value (see per-type details below)
  - An "Insert" button/control for that specific row
- Additionally: an "Insert All" button — insert default test values for all types at once.
- After insertion — visual feedback (✅/❌ icon next to the row, or a toast/alert with the result).

### 3. List of Supported Data Types

**HKCategoryTypeIdentifier (Category samples):**
| Identifier | Value source |
|---|---|
| `intermenstrualBleeding` | `HKCategoryValueNotApplicable` (flag, no options) |
| `infrequentMenstrualCycles` | `HKCategoryValueNotApplicable` |
| `irregularMenstrualCycles` | `HKCategoryValueNotApplicable` |
| `persistentIntermenstrualBleeding` | `HKCategoryValueNotApplicable` |
| `prolongedMenstrualPeriods` | `HKCategoryValueNotApplicable` |
| `pregnancy` | `HKCategoryValueNotApplicable` |
| `contraceptive` | `HKCategoryValueContraceptive` (enum: `.unspecified`, `.implant`, `.injection`, `.intrauterineDevice`, `.intravaginalRing`, `.oral`, `.patch`) — implement as a Picker |
| `hypertensionEvent` | `HKCategoryValueNotApplicable` |
| `sleepApneaEvent` | `HKCategoryValueNotApplicable` |
| `appleSleepingBreathingDisturbances` | confirm exact enum during implementation (possibly severity-based) |
| Cardiac event types (to be confirmed — exact identifiers from the `semyon-add_datatypes` branch) | confirm value enum for each |

**HKQuantityTypeIdentifier (Quantity samples):**
| Identifier | Unit | Example value |
|---|---|---|
| `atrialFibrillationBurden` | `HKUnit.percent()` | 0.0–1.0, e.g. 0.15 |

> ⚠️ Important: `atrialFibrillationBurden` is a **Quantity type**, not a Category type, despite looking similar to the other cardiac types. Its insertion logic differs from Category types (see section 4).

### 4. Data Insertion Logic

Two separate methods:

```swift
func insertCategorySample(identifier: HKCategoryTypeIdentifier, value: Int, start: Date, end: Date)
func insertQuantitySample(identifier: HKQuantityTypeIdentifier, value: Double, unit: HKUnit, start: Date, end: Date)
```

- For types using `HKCategoryValueNotApplicable` — pass `HKCategoryValueNotApplicable.notApplicable.rawValue` as the value; no separate value input control is needed (only dates).
- For `contraceptive` — a Picker with the enum's cases, converted to `.rawValue` on selection.
- For `atrialFibrillationBurden` — a numeric input field (0–100%, convert to 0.0–1.0 before saving).
- Every insertion should let the user set the `start`/`end` date (defaulting to the current moment, but adjustable, in order to test different date ranges in the pipeline).

### 5. Error Handling
- If `save()` returns an error — show the error text in the UI (not just in the console).
- Separately handle the case of "type not supported on this iOS/Simulator version" (some identifiers require iOS 16+/17+/18+ — confirm and add `#available` checks where needed).

## Language

All code (variable/function/file names), UI text (labels, alerts, button titles), and code comments must be **in English only**.

## Non-Functional Requirements

- SwiftUI, minimum iOS version matching the SDK project's current target (to confirm, likely iOS 17+).
- No networking, no persistence outside HealthKit — the app should be fully stateless between launches (optionally, remembered default values via `@AppStorage`, but this is optional).
- A single screen is sufficient — no navigation needed.
- Code should be readable and easily extensible: adding a new data type should just mean adding a new entry to the configuration array/dictionary, without changing UI logic.

## Proposed Project Structure

```
HealthKitInjector/
├── HealthKitInjectorApp.swift       // Entry point, requests authorization on launch
├── HealthKitManager.swift           // insertCategorySample / insertQuantitySample, requestAuthorization
├── DataTypeConfig.swift             // Configuration for all types (identifier, display name, value type, options)
├── ContentView.swift                // List of types + Insert All
└── DataTypeRow.swift                // Individual list row with value input control
```

## Definition of Done

1. The app builds and runs on the iOS Simulator.
2. On first launch, write access is requested and granted for all types in the list.
3. Each type in the list can be manually inserted, with visible success feedback.
4. Inserted data is visible in the Health app (Browse → corresponding category → Data Sources shows the app).
5. Inserted data is correctly picked up by HealthKit consumers on the next read.

## Open Questions (to confirm before/during implementation)

- Exact list of "cardiac event types" mentioned in the task — need their `HKCategoryTypeIdentifier`/`HKQuantityTypeIdentifier` names from the `semyon-add_datatypes` branch.
- Value enum for `appleSleepingBreathingDisturbances` — needs verification in Apple's docs/HealthKit headers.
- Minimum supported iOS version per type (some identifiers were introduced in iOS 18).

# HealthKit Injector

Standalone SwiftUI iOS app for manually injecting test data into HealthKit via Simulator.
Used to test HealthKit SDK read pipelines for types Health.app can't enter manually.

## Running

1. Open `HealthKitInjector.xcodeproj` in Xcode
2. Select any iPhone Simulator (iOS 17+)
3. Build & Run (`⌘R`)
4. Grant HealthKit permissions on first launch
5. Pick a data type, set value and date range, tap **Insert**

## Project

- **Xcode:** 26.3 · **Target:** iOS 17.0 · **Bundle:** `com.example.HealthKitInjector`
- **Project file:** `HealthKitInjector.xcodeproj`
- **Spec:** `healthkit_injector_spec_en.md` · **Type list:** `healthkit_datatypes.md`

## Structure

```
HealthKitInjector/
├── DataTypeConfig.swift     — all type configs; single source of truth
├── HealthKitManager.swift   — HK authorization + insertion (category / quantity)
├── DataTypeRow.swift        — per-row UI: flag / enum picker / numeric input + date range
├── ContentView.swift        — grouped list + Insert All button
└── HealthKitInjectorApp.swift
```

## Adding a New Data Type

All changes live in **two files only**: `DataTypeConfig.swift` and `HealthKitManager.swift`.

### Step 1 — Add authorization (`HealthKitManager.swift`)

Inside `requestAuthorization()`, add the type to the appropriate availability block:

```swift
// iOS 17+ (target minimum) — add directly:
addCategory(.yourNewCategoryType)
addQuantity(.yourNewQuantityType)

// iOS 18+ — inside existing block:
if #available(iOS 18.0, *) {
    addCategory(.yourNewType)
}

// iOS 26.2+ — inside existing block:
if #available(iOS 26.2, *) {
    addCategory(.yourNewType)
}
```

### Step 2 — Add config (`DataTypeConfig.swift`)

Inside `DataTypeConfig.all`, add one `.init(...)` entry:

#### Flag type (HKCategoryValueNotApplicable)
```swift
.init(
    displayName: "Human Readable Name",
    technicalId: "hkIdentifierString",
    groupName: "Group Name",           // "Reproductive Health" | "Heart" | "Activity" | etc.
    kind: .category(.yourIdentifier),
    input: .notApplicable
)
```

#### Enum picker (category with discrete values)
Hardcode raw values from HealthKit headers — they are stable ABI.
```swift
.init(
    displayName: "Contraceptive",
    technicalId: "contraceptive",
    groupName: "Reproductive Health",
    kind: .category(.contraceptive),
    input: .categoryEnum(options: [
        .init(label: "Unspecified", rawValue: 0),   // HKCategoryValueContraceptive.unspecified
        .init(label: "Oral",        rawValue: 5),
        // ...
    ])
)
```

#### Numeric quantity
```swift
.init(
    displayName: "Stair Ascent Speed",
    technicalId: "stairAscentSpeed",
    groupName: "Mobility",
    kind: .quantity(.stairAscentSpeed),
    input: .quantity(
        unit: HKUnit.meter().unitDivided(by: .second()),
        displayUnit: "m/s",
        defaultValue: 0.5,
        min: 0.0,
        max: 5.0,
        hint: "Meters per second (e.g. 0.5)"
    )
)
```

For iOS 18+ or 26.2+ types, place the `.init(...)` inside the matching `if #available` block at the bottom of `DataTypeConfig.all`.

### Step 3 — Verify availability

**Always** check the real SDK headers before assuming iOS version from docs:
```bash
grep "YourIdentifier" \
  /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/System/Library/Frameworks/HealthKit.framework/Headers/HKTypeIdentifiers.h
```

Apple's online docs lag behind; Xcode 26.x SDK uses new version numbering (iOS 26.x = old iOS 19+).

## Apple Watch-Only Types (Cannot Inject)

`requestAuthorization(toShare:)` **throws an exception** if these types are included — they are write-restricted to Apple devices only. Third-party apps get read-only access.

| Identifier | Reason |
|---|---|
| `infrequentMenstrualCycles` | Apple Watch algorithm |
| `irregularMenstrualCycles` | Apple Watch algorithm |
| `persistentIntermenstrualBleeding` | Apple Watch algorithm |
| `prolongedMenstrualPeriods` | Apple Watch algorithm |
| `appleStandHour` | Apple Watch sensor |
| `appleMoveTime` | Apple Watch sensor |
| `appleStandTime` | Apple Watch sensor |
| `lowCardioFitnessEvent` | Apple Watch algorithm |
| `atrialFibrillationBurden` | Apple Watch ECG |
| `sleepApneaEvent` | Apple Watch sleep monitoring |
| `appleSleepingBreathingDisturbances` | Apple Watch sleep monitoring |
| `hypertensionEvent` | Apple Watch (iOS 26.2+) |

These types are **excluded from the app entirely**. To test SDK reads for these types, use a real Apple Watch or mock the data in unit tests.

## Known Availability Surprises

| Identifier | Expected | Actual (Xcode 26.3 SDK) |
|---|---|---|
| `hypertensionEvent` | iOS 16 | **iOS 26.2+** |
| `bleedingDuringPregnancy` | iOS 16 | **iOS 18+** |
| `bleedingAfterPregnancy` | iOS 18 | iOS 18+ ✓ |
| `appleSleepingBreathingDisturbances` | Category, iOS 18 | **Quantity** (count), iOS 18+ |

## HKUnit Quick Reference

| Unit | Code |
|---|---|
| Celsius | `.degreeCelsius()` |
| Percent (fraction 0–1) | `.percent()` |
| Meters | `.meter()` |
| m/s | `HKUnit.meter().unitDivided(by: .second())` |
| Minutes | `.minute()` |
| Count | `.count()` |
| dBASPL | `.decibelAWeightedSoundPressureLevel()` |

**Note:** `HKUnit.percent()` stores 0.0–1.0 (1.0 = 100%). Enter the raw fraction in the UI.

## Rebuilding xcodeproj

Add the new Swift file to the Xcode project via **File → Add Files to "HealthKitInjector"**.

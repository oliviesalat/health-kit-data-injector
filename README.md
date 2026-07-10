# HealthKit Injector

Standalone SwiftUI app for manually injecting test data into HealthKit on iOS Simulator.

Covers HealthKit types that the Health app cannot enter manually — reproductive health, mobility, hearing, diving, and others.

## Requirements

- Xcode 26.3+
- iOS 17.0+ Simulator

## Usage

1. Open `HealthKitInjector.xcodeproj` in Xcode
2. Run on an iOS Simulator
3. Grant HealthKit permissions when prompted
4. Select a data type, configure value and date range, tap **Insert**

## Supported Types

| Group | Types |
|---|---|
| Reproductive Health | Contraceptive, Pregnancy Test Result, Progesterone Test Result, Intermenstrual Bleeding, Pregnancy, Lactation, Basal Body Temperature |
| Reproductive Health (iOS 18+) | Bleeding During Pregnancy, Bleeding After Pregnancy |
| Mobility | Stair Ascent Speed, Stair Descent Speed |
| Hearing | Environmental Audio Exposure, Headphone Audio Exposure |
| Diving | Underwater Depth, Water Temperature |
| Other | Blood Alcohol Content, Number of Alcoholic Beverages, Number of Times Fallen, Peripheral Perfusion Index |

## Adding New Types

See [CLAUDE.md](CLAUDE.md) for step-by-step instructions.

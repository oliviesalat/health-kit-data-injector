import HealthKit

struct EnumOption: Identifiable {
    let id = UUID()
    let label: String
    let rawValue: Int
}

enum DataInput {
    /// Flag sample — no value input, always writes HKCategoryValue.notApplicable
    case notApplicable
    /// Picker-driven category enum
    case categoryEnum(options: [EnumOption])
    /// Numeric text field; value is stored directly with the given unit
    case quantity(unit: HKUnit, displayUnit: String, defaultValue: Double, min: Double, max: Double, hint: String)
}

enum DataKind {
    case category(HKCategoryTypeIdentifier)
    case quantity(HKQuantityTypeIdentifier)
}

struct DataTypeConfig: Identifiable {
    let id = UUID()
    let displayName: String
    let technicalId: String
    let groupName: String
    let kind: DataKind
    let input: DataInput

    var defaultInput: DataValueInput {
        switch input {
        case .notApplicable:
            return .notApplicable
        case .categoryEnum(let opts):
            return .enumOption(opts.first?.rawValue ?? 0)
        case .quantity(_, _, let def, _, _, _):
            return .number(def)
        }
    }
}

enum DataValueInput {
    case notApplicable
    case enumOption(Int)
    case number(Double)
}

// MARK: - All Configurations
//
// Apple Watch-generated types (infrequentMenstrualCycles, irregularMenstrualCycles,
// persistentIntermenstrualBleeding, prolongedMenstrualPeriods, appleStandHour,
// appleMoveTime, appleStandTime, lowCardioFitnessEvent, atrialFibrillationBurden,
// sleepApneaEvent, appleSleepingBreathingDisturbances, hypertensionEvent) are excluded —
// requestAuthorization(toShare:) throws for these types; they are write-restricted
// to Apple devices only.

extension DataTypeConfig {
    static var all: [DataTypeConfig] {
        var configs: [DataTypeConfig] = [

            // MARK: Reproductive Health — flag types
            .init(
                displayName: "Intermenstrual Bleeding",
                technicalId: "intermenstrualBleeding",
                groupName: "Reproductive Health",
                kind: .category(.intermenstrualBleeding),
                input: .notApplicable
            ),
            .init(
                displayName: "Pregnancy",
                technicalId: "pregnancy",
                groupName: "Reproductive Health",
                kind: .category(.pregnancy),
                input: .notApplicable
            ),
            .init(
                displayName: "Lactation",
                technicalId: "lactation",
                groupName: "Reproductive Health",
                kind: .category(.lactation),
                input: .notApplicable
            ),

            // MARK: Reproductive Health — enum pickers
            .init(
                displayName: "Contraceptive",
                technicalId: "contraceptive",
                groupName: "Reproductive Health",
                kind: .category(.contraceptive),
                // HKCategoryValueContraceptive raw values (stable ABI)
                input: .categoryEnum(options: [
                    .init(label: "Unspecified", rawValue: 1),
                    .init(label: "Implant", rawValue: 2),
                    .init(label: "Injection", rawValue: 3),
                    .init(label: "Intrauterine Device", rawValue: 4),
                    .init(label: "Intravaginal Ring", rawValue: 5),
                    .init(label: "Oral", rawValue: 6),
                    .init(label: "Patch", rawValue: 7),
                ])
            ),
            .init(
                displayName: "Pregnancy Test Result",
                technicalId: "pregnancyTestResult",
                groupName: "Reproductive Health",
                kind: .category(.pregnancyTestResult),
                // HKCategoryValuePregnancyTestResult raw values
                input: .categoryEnum(options: [
                    .init(label: "Negative", rawValue: 1),
                    .init(label: "Positive", rawValue: 2),
                    .init(label: "Indeterminate", rawValue: 3),
                ])
            ),
            .init(
                displayName: "Progesterone Test Result",
                technicalId: "progesteroneTestResult",
                groupName: "Reproductive Health",
                kind: .category(.progesteroneTestResult),
                // HKCategoryValueProgesteroneTestResult raw values
                input: .categoryEnum(options: [
                    .init(label: "Negative", rawValue: 1),
                    .init(label: "Positive", rawValue: 2),
                    .init(label: "Indeterminate", rawValue: 3),
                ])
            ),

            // MARK: Reproductive Health — quantity
            .init(
                displayName: "Basal Body Temperature",
                technicalId: "basalBodyTemperature",
                groupName: "Reproductive Health",
                kind: .quantity(.basalBodyTemperature),
                input: .quantity(
                    unit: .degreeCelsius(),
                    displayUnit: "°C",
                    defaultValue: 36.5,
                    min: 35.0,
                    max: 42.0,
                    hint: "Celsius, e.g. 36.5"
                )
            ),

            // MARK: Mobility
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
            ),
            .init(
                displayName: "Stair Descent Speed",
                technicalId: "stairDescentSpeed",
                groupName: "Mobility",
                kind: .quantity(.stairDescentSpeed),
                input: .quantity(
                    unit: HKUnit.meter().unitDivided(by: .second()),
                    displayUnit: "m/s",
                    defaultValue: 0.4,
                    min: 0.0,
                    max: 5.0,
                    hint: "Meters per second (e.g. 0.4)"
                )
            ),

            // MARK: Hearing
            .init(
                displayName: "Environmental Audio Exposure",
                technicalId: "environmentalAudioExposure",
                groupName: "Hearing",
                kind: .quantity(.environmentalAudioExposure),
                input: .quantity(
                    unit: .decibelAWeightedSoundPressureLevel(),
                    displayUnit: "dBASPL",
                    defaultValue: 70.0,
                    min: 0.0,
                    max: 140.0,
                    hint: "Decibels A-weighted (0–140)"
                )
            ),
            .init(
                displayName: "Headphone Audio Exposure",
                technicalId: "headphoneAudioExposure",
                groupName: "Hearing",
                kind: .quantity(.headphoneAudioExposure),
                input: .quantity(
                    unit: .decibelAWeightedSoundPressureLevel(),
                    displayUnit: "dBASPL",
                    defaultValue: 70.0,
                    min: 0.0,
                    max: 140.0,
                    hint: "Decibels A-weighted (0–140)"
                )
            ),

            // MARK: Diving
            .init(
                displayName: "Underwater Depth",
                technicalId: "underwaterDepth",
                groupName: "Diving",
                kind: .quantity(.underwaterDepth),
                input: .quantity(
                    unit: .meter(),
                    displayUnit: "m",
                    defaultValue: 5.0,
                    min: 0.0,
                    max: 100.0,
                    hint: "Depth in meters"
                )
            ),
            .init(
                displayName: "Water Temperature",
                technicalId: "waterTemperature",
                groupName: "Diving",
                kind: .quantity(.waterTemperature),
                input: .quantity(
                    unit: .degreeCelsius(),
                    displayUnit: "°C",
                    defaultValue: 20.0,
                    min: -2.0,
                    max: 40.0,
                    hint: "Celsius (e.g. 20)"
                )
            ),

            // MARK: Other
            .init(
                displayName: "Blood Alcohol Content",
                technicalId: "bloodAlcoholContent",
                groupName: "Other",
                kind: .quantity(.bloodAlcoholContent),
                // HKUnit.percent() stores fraction; 0.0008 = 0.08% BAC
                input: .quantity(
                    unit: .percent(),
                    displayUnit: "(fraction)",
                    defaultValue: 0.0008,
                    min: 0.0,
                    max: 0.5,
                    hint: "Fraction (e.g. 0.0008 = 0.08% BAC)"
                )
            ),
            .init(
                displayName: "Number of Alcoholic Beverages",
                technicalId: "numberOfAlcoholicBeverages",
                groupName: "Other",
                kind: .quantity(.numberOfAlcoholicBeverages),
                input: .quantity(
                    unit: .count(),
                    displayUnit: "drinks",
                    defaultValue: 2.0,
                    min: 0,
                    max: 50,
                    hint: "Standard drink count"
                )
            ),
            .init(
                displayName: "Number of Times Fallen",
                technicalId: "numberOfTimesFallen",
                groupName: "Other",
                kind: .quantity(.numberOfTimesFallen),
                input: .quantity(
                    unit: .count(),
                    displayUnit: "falls",
                    defaultValue: 1.0,
                    min: 0,
                    max: 100,
                    hint: "Fall count"
                )
            ),
            .init(
                displayName: "Peripheral Perfusion Index",
                technicalId: "peripheralPerfusionIndex",
                groupName: "Other",
                kind: .quantity(.peripheralPerfusionIndex),
                // HKUnit.percent() stores fraction; 0.04 = 4% PPI
                input: .quantity(
                    unit: .percent(),
                    displayUnit: "(fraction)",
                    defaultValue: 0.04,
                    min: 0.0,
                    max: 0.2,
                    hint: "Fraction (e.g. 0.04 = 4%)"
                )
            ),
        ]

        // MARK: iOS 18+ types
        if #available(iOS 18.0, *) {
            configs += [
                .init(
                    displayName: "Bleeding During Pregnancy",
                    technicalId: "bleedingDuringPregnancy",
                    groupName: "Reproductive Health",
                    kind: .category(.bleedingDuringPregnancy),
                    // HKCategoryValueVaginalBleeding raw values
                    input: .categoryEnum(options: [
                        .init(label: "Unspecified", rawValue: 1),
                        .init(label: "Light", rawValue: 2),
                        .init(label: "Medium", rawValue: 3),
                        .init(label: "Heavy", rawValue: 4),
                        .init(label: "None", rawValue: 5),
                    ])
                ),
                .init(
                    displayName: "Bleeding After Pregnancy",
                    technicalId: "bleedingAfterPregnancy",
                    groupName: "Reproductive Health",
                    kind: .category(.bleedingAfterPregnancy),
                    // HKCategoryValueVaginalBleeding raw values
                    input: .categoryEnum(options: [
                        .init(label: "Unspecified", rawValue: 1),
                        .init(label: "Light", rawValue: 2),
                        .init(label: "Medium", rawValue: 3),
                        .init(label: "Heavy", rawValue: 4),
                        .init(label: "None", rawValue: 5),
                    ])
                ),
            ]
        }

        return configs
    }
}

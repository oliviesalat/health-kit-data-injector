import HealthKit

@MainActor
class HealthKitManager: ObservableObject {

    private let store = HKHealthStore()

    enum AuthStatus { case unknown, authorized, denied }
    @Published var authorizationStatus: AuthStatus = .unknown

    // MARK: - Authorization

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            authorizationStatus = .denied
            return
        }

        var types: Set<HKSampleType> = []

        func addCategory(_ id: HKCategoryTypeIdentifier) {
            if let t = HKObjectType.categoryType(forIdentifier: id) { types.insert(t) }
        }
        func addQuantity(_ id: HKQuantityTypeIdentifier) {
            if let t = HKObjectType.quantityType(forIdentifier: id) { types.insert(t) }
        }

        // Writable category types (third-party apps allowed)
        // Apple Watch-generated types (infrequentMenstrualCycles, irregularMenstrualCycles,
        // persistentIntermenstrualBleeding, prolongedMenstrualPeriods, appleStandHour,
        // lowCardioFitnessEvent, sleepApneaEvent, hypertensionEvent) are NOT writable
        // by third-party apps — requestAuthorization throws if included in toShare.
        addCategory(.intermenstrualBleeding)
        addCategory(.pregnancy)
        addCategory(.contraceptive)
        addCategory(.lactation)
        addCategory(.pregnancyTestResult)
        addCategory(.progesteroneTestResult)

        // iOS 18+
        if #available(iOS 18.0, *) {
            addCategory(.bleedingDuringPregnancy)
            addCategory(.bleedingAfterPregnancy)
        }

        // Writable quantity types
        // Apple Watch-only types (atrialFibrillationBurden, appleMoveTime, appleStandTime,
        // appleSleepingBreathingDisturbances) are NOT writable by third-party apps.
        addQuantity(.basalBodyTemperature)
        addQuantity(.stairAscentSpeed)
        addQuantity(.stairDescentSpeed)
        addQuantity(.environmentalAudioExposure)
        addQuantity(.headphoneAudioExposure)
        addQuantity(.underwaterDepth)
        addQuantity(.waterTemperature)
        addQuantity(.bloodAlcoholContent)
        addQuantity(.numberOfAlcoholicBeverages)
        addQuantity(.numberOfTimesFallen)
        addQuantity(.peripheralPerfusionIndex)

        do {
            try await store.requestAuthorization(toShare: types, read: [])
            authorizationStatus = .authorized
        } catch {
            authorizationStatus = .denied
        }
    }

    // MARK: - Insertion

    func insert(config: DataTypeConfig, valueInput: DataValueInput, startDate: Date, endDate: Date) async throws {
        switch config.kind {
        case .category(let identifier):
            let rawValue: Int
            switch valueInput {
            case .notApplicable:
                rawValue = HKCategoryValue.notApplicable.rawValue
            case .enumOption(let v):
                rawValue = v
            case .number:
                throw InjectorError.wrongInputType
            }
            try await insertCategorySample(identifier: identifier, value: rawValue, start: startDate, end: endDate)

        case .quantity(let identifier):
            guard case .number(let doubleValue) = valueInput else { throw InjectorError.wrongInputType }
            guard case .quantity(let unit, _, _, _, _, _) = config.input else { throw InjectorError.wrongInputType }
            try await insertQuantitySample(identifier: identifier, value: doubleValue, unit: unit, start: startDate, end: endDate)
        }
    }

    // MARK: - Primitives

    func insertCategorySample(
        identifier: HKCategoryTypeIdentifier,
        value: Int,
        start: Date,
        end: Date
    ) async throws {
        guard let type = HKObjectType.categoryType(forIdentifier: identifier) else {
            throw InjectorError.typeUnavailable(identifier.rawValue)
        }
        let sample = HKCategorySample(type: type, value: value, start: start, end: end)
        try await store.save(sample)
    }

    func insertQuantitySample(
        identifier: HKQuantityTypeIdentifier,
        value: Double,
        unit: HKUnit,
        start: Date,
        end: Date
    ) async throws {
        guard let type = HKObjectType.quantityType(forIdentifier: identifier) else {
            throw InjectorError.typeUnavailable(identifier.rawValue)
        }
        let quantity = HKQuantity(unit: unit, doubleValue: value)
        let sample = HKQuantitySample(type: type, quantity: quantity, start: start, end: end)
        try await store.save(sample)
    }

    // MARK: - Watch-restricted mock

    struct WatchMockResult: Identifiable {
        let id = UUID()
        let typeName: String
        let success: Bool
        let error: String?
    }

    func insertWatchMockSamples() async -> [WatchMockResult] {
        let now = Date()
        let start = now.addingTimeInterval(-3600)
        var results: [WatchMockResult] = []

        // Request read-only auth to avoid the toShare: exception
        var readTypes: Set<HKSampleType> = []
        let ids: [HKCategoryTypeIdentifier] = [
            .infrequentMenstrualCycles,
            .irregularMenstrualCycles,
            .persistentIntermenstrualBleeding,
            .prolongedMenstrualPeriods,
        ]
        for id in ids {
            if let t = HKObjectType.categoryType(forIdentifier: id) { readTypes.insert(t) }
        }
        if #available(iOS 26.2, *) {
            if let t = HKObjectType.categoryType(forIdentifier: .hypertensionEvent) { readTypes.insert(t) }
        }
        try? await store.requestAuthorization(toShare: [], read: readTypes)

        // Attempt save without write auth — may succeed on Simulator
        let namedIds: [(String, HKCategoryTypeIdentifier)] = [
            ("Infrequent Menstrual Cycles", .infrequentMenstrualCycles),
            ("Irregular Menstrual Cycles", .irregularMenstrualCycles),
            ("Persistent Intermenstrual Bleeding", .persistentIntermenstrualBleeding),
            ("Prolonged Menstrual Periods", .prolongedMenstrualPeriods),
        ]
        for (name, identifier) in namedIds {
            do {
                try await insertCategorySample(
                    identifier: identifier,
                    value: HKCategoryValue.notApplicable.rawValue,
                    start: start,
                    end: now
                )
                results.append(.init(typeName: name, success: true, error: nil))
            } catch {
                results.append(.init(typeName: name, success: false, error: error.localizedDescription))
            }
        }

        if #available(iOS 26.2, *) {
            do {
                try await insertCategorySample(
                    identifier: .hypertensionEvent,
                    value: HKCategoryValue.notApplicable.rawValue,
                    start: start,
                    end: now
                )
                results.append(.init(typeName: "Hypertension Event", success: true, error: nil))
            } catch {
                results.append(.init(typeName: "Hypertension Event", success: false, error: error.localizedDescription))
            }
        }

        return results
    }
}

// MARK: - Errors

enum InjectorError: LocalizedError {
    case typeUnavailable(String)
    case wrongInputType

    var errorDescription: String? {
        switch self {
        case .typeUnavailable(let id):
            return "Type '\(id)' is not available on this OS version."
        case .wrongInputType:
            return "Internal error: mismatched input type."
        }
    }
}

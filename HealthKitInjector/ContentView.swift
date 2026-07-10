import SwiftUI

struct ContentView: View {
    @StateObject private var hkManager = HealthKitManager()

    @State private var watchMockResults: [HealthKitManager.WatchMockResult] = []
    @State private var showWatchMockSheet = false

    private let configs = DataTypeConfig.all

    private var groupedConfigs: [(String, [DataTypeConfig])] {
        let order = ["Reproductive Health", "Heart", "Activity", "Mobility", "Hearing", "Diving", "Sleep", "Other"]
        var dict: [String: [DataTypeConfig]] = [:]
        for c in configs { dict[c.groupName, default: []].append(c) }
        var result = order.compactMap { key -> (String, [DataTypeConfig])? in
            guard let items = dict[key], !items.isEmpty else { return nil }
            return (key, items)
        }
        // Append any groups not in order list
        let covered = Set(order)
        for (key, items) in dict where !covered.contains(key) {
            result.append((key, items))
        }
        return result
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    statusBadge
                }

                ForEach(groupedConfigs, id: \.0) { groupName, items in
                    Section(header: Text(groupName)) {
                        ForEach(items) { config in
                            DataTypeRow(config: config) { valueInput, start, end in
                                try await hkManager.insert(
                                    config: config,
                                    valueInput: valueInput,
                                    startDate: start,
                                    endDate: end
                                )
                            }
                        }
                    }
                }

                Section(header: Text("Watch-Restricted Mock")) {
                    Button("Try Inject Watch Types") {
                        Task {
                            watchMockResults = await hkManager.insertWatchMockSamples()
                            showWatchMockSheet = true
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("HealthKit Injector")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Insert All") {
                        Task { await insertAll() }
                    }
                    .disabled(hkManager.authorizationStatus != .authorized)
                }
            }
        }
        .sheet(isPresented: $showWatchMockSheet) {
            WatchMockResultsView(results: watchMockResults)
                .presentationDetents([.medium])
        }
        .task {
            await hkManager.requestAuthorization()
        }
    }

    // MARK: - Status badge

    private var statusBadge: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            Text(statusText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .listRowBackground(Color.clear)
    }

    private var statusColor: Color {
        switch hkManager.authorizationStatus {
        case .authorized: return .green
        case .denied:     return .red
        case .unknown:    return .gray
        }
    }

    private var statusText: String {
        switch hkManager.authorizationStatus {
        case .authorized: return "HealthKit connected"
        case .denied:     return "HealthKit access denied"
        case .unknown:    return "Requesting HealthKit access…"
        }
    }

    // MARK: - Insert All

    private func insertAll() async {
        let now = Date()
        for config in configs {
            try? await hkManager.insert(
                config: config,
                valueInput: config.defaultInput,
                startDate: now.addingTimeInterval(-3600),
                endDate: now
            )
        }
    }
}

// MARK: - Watch mock results sheet

private struct WatchMockResultsView: View {
    let results: [HealthKitManager.WatchMockResult]

    var body: some View {
        NavigationStack {
            List(results) { result in
                HStack {
                    Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(result.success ? .green : .red)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.typeName).font(.subheadline)
                        if let err = result.error {
                            Text(err).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Watch Mock Results")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

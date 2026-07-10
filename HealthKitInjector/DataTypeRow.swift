import SwiftUI

struct DataTypeRow: View {
    let config: DataTypeConfig
    let onInsert: (DataValueInput, Date, Date) async throws -> Void

    @State private var selectedEnumValue: Int
    @State private var quantityText: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var status: RowStatus = .idle

    enum RowStatus: Equatable {
        case idle, inserting, success, failed(String)
    }

    init(config: DataTypeConfig, onInsert: @escaping (DataValueInput, Date, Date) async throws -> Void) {
        self.config = config
        self.onInsert = onInsert

        let now = Date()
        _startDate = State(initialValue: now.addingTimeInterval(-3600))
        _endDate = State(initialValue: now)

        switch config.input {
        case .notApplicable:
            _selectedEnumValue = State(initialValue: 0)
            _quantityText = State(initialValue: "")
        case .categoryEnum(let opts):
            _selectedEnumValue = State(initialValue: opts.first?.rawValue ?? 0)
            _quantityText = State(initialValue: "")
        case .quantity(_, _, let def, _, _, _):
            _selectedEnumValue = State(initialValue: 0)
            _quantityText = State(initialValue: formatDefault(def))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(config.displayName)
                        .font(.headline)
                    Text(config.technicalId)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                statusIcon
                Button("Insert") {
                    Task { await performInsert() }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(status == .inserting)
            }

            // Value input control
            switch config.input {
            case .notApplicable:
                Text("Flag — no value input required")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            case .categoryEnum(let options):
                Picker("Value", selection: $selectedEnumValue) {
                    ForEach(options) { opt in
                        Text(opt.label).tag(opt.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()

            case .quantity(_, let unitLabel, _, let minVal, let maxVal, let hint):
                HStack(spacing: 6) {
                    TextField(hint, text: $quantityText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    Text(unitLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize()
                }
                Text("Range: \(formatBound(minVal)) – \(formatBound(maxVal))  ·  \(hint)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // Date range
            DatePicker("Start", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                .font(.caption)
            DatePicker("End", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                .font(.caption)

            // Error message
            if case .failed(let msg) = status {
                Text(msg)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Helpers

    @ViewBuilder
    private var statusIcon: some View {
        switch status {
        case .idle:
            EmptyView()
        case .inserting:
            ProgressView()
                .scaleEffect(0.75)
        case .success:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .failed:
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
        }
    }

    private func performInsert() async {
        status = .inserting
        let valueInput: DataValueInput
        switch config.input {
        case .notApplicable:
            valueInput = .notApplicable
        case .categoryEnum:
            valueInput = .enumOption(selectedEnumValue)
        case .quantity:
            guard let v = Double(quantityText.replacingOccurrences(of: ",", with: ".")) else {
                status = .failed("Invalid number: \"\(quantityText)\"")
                return
            }
            valueInput = .number(v)
        }

        let end = max(startDate, endDate)
        do {
            try await onInsert(valueInput, startDate, end)
            status = .success
        } catch {
            status = .failed(error.localizedDescription)
        }
    }
}

// MARK: - Formatting helpers (file-private)

private func formatDefault(_ v: Double) -> String {
    if v == v.rounded() && abs(v) < 1_000_000 {
        return String(format: "%.0f", v)
    }
    return String(v)
}

private func formatBound(_ v: Double) -> String {
    v.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(v)) : String(v)
}

import SwiftUI

struct Trade: Identifiable, Codable {
    var id = UUID()
    var date = Date()
    var symbol: String
    var entry: Double
    var stop: Double
    var exit: Double
    var note: String
    var isLong: Bool { stop < entry }
    var r: Double { let d = entry - stop; return d == 0 ? 0 : (exit - entry) / d }
}

final class JournalStore: ObservableObject {
    private let key = "trades.v1"
    @Published var trades: [Trade] = [] { didSet { save() } }
    init() {
        if let d = UserDefaults.standard.data(forKey: key),
           let t = try? JSONDecoder().decode([Trade].self, from: d) { trades = t }
    }
    private func save() {
        if let d = try? JSONEncoder().encode(trades) { UserDefaults.standard.set(d, forKey: key) }
    }
    var totalR: Double { trades.reduce(0) { $0 + $1.r } }
    var winRate: Double {
        trades.isEmpty ? 0 : Double(trades.filter { $0.r > 0 }.count) / Double(trades.count) * 100
    }
    var avgR: Double { trades.isEmpty ? 0 : totalR / Double(trades.count) }
}

struct JournalView: View {
    @EnvironmentObject var store: JournalStore
    @State private var adding = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Stat(title: "Trades", value: "\(store.trades.count)")
                        Stat(title: "Win rate", value: String(format: "%.0f%%", store.winRate))
                        Stat(title: "Total R", value: String(format: "%+.1f", store.totalR),
                             color: store.totalR >= 0 ? .up : .down)
                        Stat(title: "Avg R", value: String(format: "%+.2f", store.avgR))
                    }
                }.listRowBackground(Color.card)

                Section("Trades") {
                    if store.trades.isEmpty {
                        Text("No trades yet. Tap + to add one.").foregroundColor(.muted)
                    }
                    ForEach(store.trades.sorted { $0.date > $1.date }) { t in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(t.symbol) · \(t.isLong ? "LONG" : "SHORT")").font(.headline)
                                Text(t.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption).foregroundColor(.muted)
                                if !t.note.isEmpty { Text(t.note).font(.caption) }
                            }
                            Spacer()
                            Text(String(format: "%+.2f R", t.r))
                                .font(.headline.monospacedDigit())
                                .foregroundColor(t.r >= 0 ? .up : .down)
                        }
                    }
                    .onDelete { idx in
                        let sorted = store.trades.sorted { $0.date > $1.date }
                        let ids = idx.map { sorted[$0].id }
                        store.trades.removeAll { ids.contains($0.id) }
                    }
                }.listRowBackground(Color.card)
            }
            .scrollContentBackground(.hidden)
            .background(Color.bg.ignoresSafeArea())
            .navigationTitle("Journal")
            .toolbar {
                Button { adding = true } label: { Image(systemName: "plus") }
            }
            .sheet(isPresented: $adding) { AddTradeView().environmentObject(store) }
        }
    }
}

struct AddTradeView: View {
    @EnvironmentObject var store: JournalStore
    @Environment(\.dismiss) var dismiss
    @State private var symbol = "XAUUSD"
    @State private var entry = ""
    @State private var stop = ""
    @State private var exit = ""
    @State private var note = ""

    var valid: Bool { num(entry) > 0 && num(stop) > 0 && num(exit) > 0 && num(entry) != num(stop) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Symbol").font(.caption).foregroundColor(.muted)
                        TextField("XAUUSD", text: $symbol).textInputAutocapitalization(.characters)
                            .padding(10).background(Color.bg).cornerRadius(10)
                    }
                    HStack(spacing: 12) {
                        Field(title: "Entry", text: $entry)
                        Field(title: "Stop", text: $stop)
                    }
                    Field(title: "Exit", text: $exit)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Note (setup, mistake, lesson)").font(.caption).foregroundColor(.muted)
                        TextField("e.g. FVG + London sweep", text: $note, axis: .vertical)
                            .lineLimit(3...5).padding(10).background(Color.bg).cornerRadius(10)
                    }
                }.card().padding()
            }
            .background(Color.bg.ignoresSafeArea())
            .navigationTitle("New trade")
            .keyboardDone()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.trades.append(Trade(symbol: symbol.uppercased(), entry: num(entry),
                                                  stop: num(stop), exit: num(exit), note: note))
                        dismiss()
                    }.disabled(!valid)
                }
            }
        }
    }
}

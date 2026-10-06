import SwiftUI

struct Instrument: Hashable {
    let name: String
    let contract: Double // units per 1.00 lot (check your broker)
}
let instruments = [
    Instrument(name: "XAUUSD", contract: 100),
    Instrument(name: "EURUSD", contract: 100_000),
    Instrument(name: "GBPUSD", contract: 100_000),
    Instrument(name: "BTCUSD", contract: 1),
    Instrument(name: "NAS100", contract: 1),
    Instrument(name: "US30", contract: 1),
]

struct PositionSizeView: View {
    @State private var inst = instruments[0]
    @State private var balance = "10000"
    @State private var riskPct = "1"
    @State private var entry = "2650.00"
    @State private var stop = "2645.00"
    @State private var contract = "100"

    var riskAmount: Double { num(balance) * num(riskPct) / 100 }
    var stopDistance: Double { abs(num(entry) - num(stop)) }
    var lots: Double {
        let d = stopDistance * num(contract)
        return d > 0 ? floor(riskAmount / d * 100) / 100 : 0
    }

    var body: some View {
        Screen(title: "Position Size") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Instrument").font(.caption).foregroundColor(.muted)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(instruments, id: \.self) { i in
                            Button {
                                inst = i
                                contract = String(format: "%g", i.contract)
                            } label: {
                                Text(i.name).font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .background(inst == i ? Color.gold : Color.bg)
                                    .foregroundColor(inst == i ? .black : .white)
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
                Field(title: "Contract size (units per lot)", text: $contract)
            }.card()

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Field(title: "Balance ($)", text: $balance)
                    Field(title: "Risk (%)", text: $riskPct)
                }
                HStack {
                    ForEach(["0.5", "1", "2"], id: \.self) { p in
                        Button("\(p)%") { riskPct = p }
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.bg).cornerRadius(14)
                    }
                    Spacer()
                }
                HStack(spacing: 12) {
                    Field(title: "Entry", text: $entry)
                    Field(title: "Stop loss", text: $stop)
                }
            }.card()

            VStack(spacing: 14) {
                Stat(title: "LOT SIZE", value: String(format: "%.2f", lots), color: .gold)
                    .font(.largeTitle)
                HStack {
                    Stat(title: "Risk", value: String(format: "$%.2f", riskAmount), color: .down)
                    Stat(title: "Stop distance", value: String(format: "%.2f", stopDistance))
                }
            }.card()

            Text("Lot size is rounded down to 0.01. Contract size varies by broker, so verify it.")
                .font(.caption).foregroundColor(.muted)
        }
    }
}

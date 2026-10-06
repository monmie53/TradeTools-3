import SwiftUI

struct RiskRewardView: View {
    @State private var entry = "2650.00"
    @State private var stop = "2645.00"
    @State private var target = "2665.00"
    @State private var winRate = 45.0

    var risk: Double { abs(num(entry) - num(stop)) }
    var reward: Double { abs(num(target) - num(entry)) }
    var rr: Double { risk > 0 ? reward / risk : 0 }
    var breakEven: Double { 100 / (1 + rr) }
    var expectancy: Double { winRate / 100 * rr - (1 - winRate / 100) }

    func setTarget(_ k: Double) {
        let e = num(entry), s = num(stop)
        target = String(format: "%.2f", e + k * (e - s))
    }

    var body: some View {
        Screen(title: "Risk : Reward") {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Field(title: "Entry", text: $entry)
                    Field(title: "Stop loss", text: $stop)
                }
                Field(title: "Take profit", text: $target)
                HStack {
                    Text("Quick TP").font(.caption).foregroundColor(.muted)
                    ForEach([1.0, 2.0, 3.0], id: \.self) { k in
                        Button("\(Int(k))R") { setTarget(k) }
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.bg).cornerRadius(14)
                    }
                    Spacer()
                }
            }.card()

            VStack(alignment: .leading, spacing: 12) {
                GeometryReader { g in
                    let total = max(risk + reward, 0.0001)
                    HStack(spacing: 2) {
                        Rectangle().fill(Color.down).frame(width: g.size.width * risk / total)
                        Rectangle().fill(Color.up)
                    }.cornerRadius(6)
                }.frame(height: 14)
                HStack {
                    Stat(title: "Risk", value: String(format: "%.2f", risk), color: .down)
                    Stat(title: "Reward", value: String(format: "%.2f", reward), color: .up)
                }
                HStack {
                    Stat(title: "R:R", value: String(format: "1 : %.2f", rr), color: .gold)
                    Stat(title: "Break-even win rate", value: String(format: "%.1f%%", breakEven))
                }
            }.card()

            VStack(alignment: .leading, spacing: 8) {
                Text(String(format: "Expected win rate: %.0f%%", winRate))
                    .font(.subheadline.weight(.semibold))
                Slider(value: $winRate, in: 10...90, step: 1)
                Stat(title: "Expectancy per trade",
                     value: String(format: "%+.2f R", expectancy),
                     color: expectancy >= 0 ? .up : .down)
            }.card()
        }
    }
}

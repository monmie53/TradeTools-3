import SwiftUI

struct Zone: Identifiable {
    let id = UUID()
    let name: String
    let startH: Int // New York time
    let endH: Int
    var start: Int { startH * 3600 }
    var end: Int { endH * 3600 }
}

struct KillzoneView: View {
    // Common ICT killzones (New York time). Edit to taste.
    let zones = [
        Zone(name: "Asian", startH: 20, endH: 24),
        Zone(name: "London", startH: 2, endH: 5),
        Zone(name: "New York AM", startH: 7, endH: 10),
        Zone(name: "London Close", startH: 10, endH: 12),
    ]
    @State private var now = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var secs: Int {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "America/New_York")!
        let p = c.dateComponents([.hour, .minute, .second], from: now)
        return (p.hour ?? 0) * 3600 + (p.minute ?? 0) * 60 + (p.second ?? 0)
    }
    func isActive(_ z: Zone) -> Bool { secs >= z.start && secs < z.end }
    func untilStart(_ z: Zone) -> Int { (z.start - secs + 86400) % 86400 }
    func hms(_ s: Int) -> String { String(format: "%02d:%02d:%02d", s / 3600, (s % 3600) / 60, s % 60) }
    func hm(_ h: Int) -> String { String(format: "%02d:00", h % 24) }

    var clock: String {
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "America/New_York")
        f.dateFormat = "HH:mm:ss"
        return f.string(from: now)
    }

    var body: some View {
        Screen(title: "Sessions") {
            VStack(alignment: .leading, spacing: 8) {
                Text("NEW YORK TIME").font(.caption).foregroundColor(.muted)
                Text(clock).font(.system(size: 44, weight: .bold, design: .rounded))
                    .monospacedDigit()
                if let a = zones.first(where: isActive) {
                    Text("\(a.name) is active").foregroundColor(.up).font(.headline)
                    ProgressView(value: Double(secs - a.start), total: Double(a.end - a.start))
                        .tint(.up)
                    Text("Ends in \(hms(a.end - secs))").font(.subheadline).foregroundColor(.muted)
                } else if let n = zones.min(by: { untilStart($0) < untilStart($1) }) {
                    Text("Next: \(n.name)").foregroundColor(.gold).font(.headline)
                    Text("Starts in \(hms(untilStart(n)))").font(.subheadline).foregroundColor(.muted)
                }
            }.card()

            ForEach(zones) { z in
                HStack {
                    Circle().fill(isActive(z) ? Color.up : Color.muted.opacity(0.4))
                        .frame(width: 12, height: 12)
                    VStack(alignment: .leading) {
                        Text(z.name).font(.headline)
                        Text("\(hm(z.startH)) – \(hm(z.endH)) NY").font(.caption).foregroundColor(.muted)
                    }
                    Spacer()
                    Text(isActive(z) ? "LIVE" : "in \(hms(untilStart(z)))")
                        .font(.caption.weight(.bold).monospacedDigit())
                        .foregroundColor(isActive(z) ? .up : .muted)
                }.card()
            }
        }
        .onReceive(timer) { now = $0 }
    }
}

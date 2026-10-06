import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
    static let bg = Color(hex: 0x0B0F14)
    static let card = Color(hex: 0x151B23)
    static let gold = Color(hex: 0xF5C451)
    static let up = Color(hex: 0x2ECC71)
    static let down = Color(hex: 0xFF5A5F)
    static let muted = Color(hex: 0x8A94A6)
}

func num(_ s: String) -> Double {
    Double(s.replacingOccurrences(of: ",", with: ".")) ?? 0
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(16).frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.card).cornerRadius(18)
    }
}
extension View {
    func card() -> some View { modifier(CardStyle()) }
    func keyboardDone() -> some View {
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil)
                }
            }
        }
    }
}

struct Field: View {
    let title: String
    @Binding var text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundColor(.muted)
            TextField("0", text: $text)
                .keyboardType(.decimalPad)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .padding(10).background(Color.bg).cornerRadius(10)
        }
    }
}

struct Stat: View {
    let title: String
    let value: String
    var color: Color = .white
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption).foregroundColor(.muted)
            Text(value).font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundColor(color).minimumScaleFactor(0.6).lineLimit(1)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct Screen<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) { content }.padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.bg.ignoresSafeArea())
            .navigationTitle(title)
            .keyboardDone()
        }
    }
}

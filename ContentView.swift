import SwiftUI

struct ContentView: View {
    @State private var automaton = CellularAutomaton(width: 100, height: 100)

    var body: some View {
        Text(self.automaton.time, format: .number)
        VStack(spacing: 1) {
            ForEach(0..<self.automaton.height, id: \.self) { y in
                HStack(spacing: 1) {
                    ForEach(0..<self.automaton.width, id: \.self) { x in
                        Rectangle()
                            .fill(self.automaton[x, y] ? .white : .black)
                            .scaledToFit()
                    }
                }
            }
        }
        .background(.black)
        .drawingGroup()
        HStack {
            Button("Clear", role: .destructive) { self.automaton.clear() }
            Button("Start") { self.automaton.start() }
            Button("Next") { self.automaton.next() }
                .keyboardShortcut("n", modifiers: .shift)
        }
        .buttonStyle(.borderedProminent)
    }
}

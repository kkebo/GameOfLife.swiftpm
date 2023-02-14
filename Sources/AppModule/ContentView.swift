import GameOfLife
import SwiftUI

struct ContentView {
    @State private var automaton = CellularAutomaton(width: 100, height: 100)
    @State private var isResetting = false
    @State private var task: Task<Void, Error>?
    private var isRunning: Bool { self.task != nil }

    private func start() {
        self.task = .detached(priority: .high) {
            while true {
                try Task.checkCancellation()
                self.automaton.next()
            }
        }
    }

    private func stop() {
        self.task?.cancel()
        self.task = nil
    }
}

extension ContentView: View {
    var body: some View {
        VStack(spacing: 5) {
            Text(self.automaton.time, format: .number)
            Canvas { context, size in
                let rectSize = CGSize(
                    width: size.width / Double(self.automaton.width),
                    height: size.height / Double(self.automaton.height)
                )
                var offset = CGPoint.zero
                for y in 0..<self.automaton.height {
                    offset.y = rectSize.height * Double(y)
                    for x in 0..<self.automaton.width {
                        guard self.automaton[x, y] else { continue }
                        offset.x = rectSize.width * Double(x)
                        context.fill(
                            Path(CGRect(origin: offset, size: rectSize)),
                            with: .color(.white)
                        )
                    }
                }
            }
            .background(.black)
            .scaledToFit()
            .onAppear {
                self.automaton.putRPentomino()
            }
            self.controls
        }
        .buttonStyle(.borderedProminent)
    }

    private var controls: some View {
        HStack {
            Button("Reset", role: .destructive) {
                self.isResetting.toggle()
            }
            .hoverEffect()
            .disabled(self.isRunning)
            .confirmationDialog("", isPresented: self.$isResetting) { 
                Button("R-pentomino") {
                    self.automaton.clear()
                    self.automaton.putRPentomino()
                }
                Button("Random") {
                    self.automaton.clear()
                    self.automaton.putRandomly()
                }
            }
            Button(!self.isRunning ? "Start" : "Stop") {
                !self.isRunning ? self.start() : self.stop()
            }
            .hoverEffect()
            Button("Next") {
                self.automaton.next()
            }
            .keyboardShortcut("n", modifiers: .shift)
            .hoverEffect()
            .disabled(self.isRunning)
        }
    }
}

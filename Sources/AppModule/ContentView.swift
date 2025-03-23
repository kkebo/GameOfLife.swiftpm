import AsyncAlgorithms
import GameOfLife
import SwiftUI

struct ContentView {
    @State private var automaton = CellularAutomaton(width: 100, height: 100)
    @State private var isResetting = false
    @State private var framesPerSecond = 60.0
    @State private var maximumFramesPerSecond = 60.0
    @State private var isRunning = false

    private func start() {
        self.isRunning = true
    }

    private func stop() {
        self.isRunning = false
    }

    @MainActor
    private func mainLoop() async {
        for await _ in AsyncTimerSequence.repeating(every: .seconds(1 / self.framesPerSecond)) {
            guard self.isRunning else { continue }
            let duration = ContinuousClock()
                .measure {
                    self.automaton.next()
                }
            print(duration)
        }
    }
}

@MainActor
extension ContentView: View {
    var body: some View {
        VStack(spacing: 5) {
            Text(self.automaton.time, format: .number)
            Canvas { context, size in
                let rectSize = CGSize(
                    width: size.width / Double(self.automaton.width),
                    height: size.height / Double(self.automaton.height)
                )
                for y in 0..<self.automaton.height {
                    let offsetY = rectSize.height * Double(y)
                    for x in 0..<self.automaton.width {
                        guard self.automaton[x, y] else { continue }
                        let offset = CGPoint(x: rectSize.width * Double(x), y: offsetY)
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
                .padding(.horizontal, 10)
        }
        .buttonStyle(.borderedProminent)
        .onAppear {
            self.framesPerSecond = Double(UIScreen.main.maximumFramesPerSecond)
            self.maximumFramesPerSecond = Double(UIScreen.main.maximumFramesPerSecond)
        }
        .task(id: self.framesPerSecond) {
            await self.mainLoop()
        }
    }

    private var controls: some View {
        VStack(spacing: 5) {
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
            HStack {
                Text("\(self.framesPerSecond, format: .number) fps")
                Slider(
                    value: self.$framesPerSecond,
                    in: 1...Double(self.maximumFramesPerSecond),
                    step: 1
                )
                .disabled(self.isRunning)
            }
        }
    }
}

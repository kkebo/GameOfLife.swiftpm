public enum Neighborhood {
    case vonNeumann
    case moore
}

public struct CellularAutomaton {
    public let width: Int
    public let height: Int
    public let neighborhood: Neighborhood
    public private(set) var time = 0
    private var map: [Bool]

    public init(width: Int, height: Int, neighborhood: Neighborhood = .moore) {
        self.width = width
        self.height = height
        self.neighborhood = neighborhood
        self.map = .init(repeating: .init(), count: height * width)
    }

    public mutating func clear() {
        self.time = 0
        for i in 0..<self.map.count {
            self.map[i] = .init()
        }
    }

    public mutating func start(random: Bool = false) {
        self.clear()
        if random {
            self.initializeMapRandomly()
        } else {
            self.initializeMapRPentomino()
        }
    }

    private mutating func initializeMapRandomly() {
        for i in 0..<self.map.count {
            self.map[i] = .random()
        }
    }

    private mutating func initializeMapRPentomino() {
        self[1, 0] = true
        self[2, 0] = true
        self[0, 1] = true
        self[1, 1] = true
        self[1, 2] = true
    }

    public mutating func next() {
        self.time += 1
        self.map = [Bool](unsafeUninitializedCapacity: self.map.count) { buffer, initializedCount in
            for y in 0..<self.height {
                for x in 0..<self.width {
                    let nextState: Bool
                    switch (self[x, y], self.countLiveNeighbors(x, y)) {
                    case (true, ...1): nextState = false
                    case (true, 2...3): nextState = true
                    case (true, 4...): nextState = false
                    case (true, _): preconditionFailure()
                    case (false, 3): nextState = true
                    case (false, _): nextState = false
                    }
                    buffer[y * self.width + x] = nextState
                    initializedCount += 1
                }
            }
        }
    }

    private func countLiveNeighbors(_ x: Int, _ y: Int) -> Int {
        let neighbors: [Bool]
        switch self.neighborhood {
        case .vonNeumann:
            neighbors = [
                self.getNeighbor(x, y - 1),
                self.getNeighbor(x - 1, y),
                self.getNeighbor(x + 1, y),
                self.getNeighbor(x, y + 1),
            ]
        case .moore:
            neighbors = [
                self.getNeighbor(x - 1, y - 1),
                self.getNeighbor(x, y - 1),
                self.getNeighbor(x + 1, y - 1),
                self.getNeighbor(x - 1, y),
                self.getNeighbor(x + 1, y),
                self.getNeighbor(x - 1, y + 1),
                self.getNeighbor(x, y + 1),
                self.getNeighbor(x + 1, y + 1),
            ]
        }
        return neighbors.lazy.filter { $0 }.count
    }

    private func getNeighbor(_ x: Int, _ y: Int) -> Bool {
        var x = x
        var y = y
        while x < 0 { x += self.width }
        while y < 0 { y += self.height }
        return self.map[(y % self.height) * self.width + (x % self.width)]
    }

    public subscript(x: Int, y: Int) -> Bool {
        get { self.map[y * self.width + x] }
        set { self.map[y * self.width + x] = newValue }
    }
}

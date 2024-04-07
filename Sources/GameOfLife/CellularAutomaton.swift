public enum Neighborhood {
    case vonNeumann
    case moore
}

/// Conway's Game of Life.
public struct CellularAutomaton {
    /// The number of columns.
    public let width: Int
    /// The number of rows.
    public let height: Int
    /// A value indicating which types of neighborhoods to use.
    public let neighborhood: Neighborhood
    /// The current time step.
    public private(set) var time = 0
    @usableFromInline var map: [Bool]

    /// An initializer.
    public init(width: Int, height: Int, neighborhood: Neighborhood = .moore) {
        self.width = width
        self.height = height
        self.neighborhood = neighborhood
        self.map = .init(repeating: false, count: height * width)
    }

    /// Resets to the initial state.
    public mutating func clear() {
        self.time = 0
        for i in self.map.indices {
            self.map[i] = false
        }
    }

    /// Puts some living cells randomly.
    public mutating func putRandomly() {
        for i in self.map.indices {
            self.map[i] = .random()
        }
    }

    /// Puts R-pentomino.
    public mutating func putRPentomino() {
        self[1, 0] = true
        self[2, 0] = true
        self[0, 1] = true
        self[1, 1] = true
        self[1, 2] = true
    }

    /// Transitions to the next step.
    public mutating func next() {
        self.time += 1
        self.map = .init(unsafeUninitializedCapacity: self.map.count) { buffer, initializedCount in
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
                }
            }
            initializedCount = self.map.count
        }
    }

    private func countLiveNeighbors(_ x: Int, _ y: Int) -> Int {
        let prevX = (x - 1 + self.width) % self.width
        let prevY = (y - 1 + self.height) % self.height
        let nextX = (x + 1) % self.width
        let nextY = (y + 1) % self.height
        let neighbors: [Bool]
        switch self.neighborhood {
        case .vonNeumann:
            neighbors = [
                self[x, prevY],
                self[prevX, y],
                self[nextX, y],
                self[x, nextY],
            ]
        case .moore:
            neighbors = [
                self[prevX, prevY],
                self[x, prevY],
                self[nextX, prevY],
                self[prevX, y],
                self[nextX, y],
                self[prevX, nextY],
                self[x, nextY],
                self[nextX, nextY],
            ]
        }
        return neighbors.lazy.filter { $0 }.count
    }

    /// Accesses the cell at the specified position.
    @inlinable
    public subscript(x: Int, y: Int) -> Bool {
        _read { yield self.map[y * self.width + x] }
        _modify { yield &self.map[y * self.width + x] }
    }
}

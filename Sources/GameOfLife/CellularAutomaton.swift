import Collections

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
    @usableFromInline var map: [BitArray]

    /// An initializer.
    public init(width: Int, height: Int, neighborhood: Neighborhood = .moore) {
        self.width = width
        self.height = height
        self.neighborhood = neighborhood
        self.map = .init(repeating: .init(repeating: false, count: width), count: height)
    }

    /// Resets to the initial state.
    public mutating func clear() {
        self.time = 0
        for i in self.map.indices {
            self.map[i].fill(with: false)
        }
    }

    /// Puts some living cells randomly.
    public mutating func putRandomly() {
        for i in self.map.indices {
            self.map[i] = .randomBits(count: self.width)
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

        var nextMap = self.map
        switch self.neighborhood {
        case .vonNeumann:
            for y in 0..<self.height {
                for x in 0..<self.width {
                    nextMap[y][x] =
                        switch (self[x, y], self.countLiveNeighbors(x, y)) {
                        case (true, ...1): false
                        case (true, 2...3): true
                        case (true, 4...): false
                        case (false, 3): true
                        case (false, _): false
                        case _: preconditionFailure()
                        }
                }
            }
        case .moore:
            let last = self.map.endIndex - 1
            let firstLine = self.map[0]
            var line = firstLine
            var next = self.map[1]
            nextMap[0] = Self.next(of: line, prev: self.map[last], next: next)
            for y in 1..<last {
                let prev = line
                (line, next) = (next, self.map[y + 1])
                nextMap[y] = Self.next(of: line, prev: prev, next: next)
            }
            nextMap[last] = Self.next(of: next, prev: line, next: firstLine)
        }
        self.map = nextMap
    }

    private static func next(of line: BitArray, prev: BitArray, next: BitArray) -> BitArray {
        var a = prev
        a.maskingShiftRight(by: 1)
        a[a.endIndex - 1] = prev[0]
        var b = prev
        var c = prev
        c.maskingShiftLeft(by: 1)
        c[0] = prev[prev.endIndex - 1]
        var d = line
        d.maskingShiftRight(by: 1)
        d[d.endIndex - 1] = line[0]
        var e = line
        e.maskingShiftLeft(by: 1)
        e[0] = line[line.endIndex - 1]
        var f = next
        f.maskingShiftRight(by: 1)
        f[f.endIndex - 1] = next[0]
        var g = next
        var h = next
        h.maskingShiftLeft(by: 1)
        h[0] = next[next.endIndex - 1]

        let xab = a & b
        a ^= b
        let xcd = c & d
        c ^= d
        let xef = e & f
        e ^= f
        let xgh = g & h
        g ^= h

        d = a & c
        a ^= c
        c = xab & xcd
        b = xab ^ xcd ^ d

        h = e & g
        e ^= g
        g = xef & xgh
        f = xef ^ xgh ^ h

        d = a & e
        a ^= e
        h = b & f
        b ^= f
        h |= b & d
        b ^= d
        c ^= g ^ h

        let x = ~c & b
        let s2 = x & ~a
        let s3 = x & a

        return ~line & s3 | line & (s2 | s3)
    }

    private func countLiveNeighbors(_ x: Int, _ y: Int) -> Int {
        let prevX = (x - 1 + self.width) % self.width
        let prevY = (y - 1 + self.height) % self.height
        let nextX = (x + 1) % self.width
        let nextY = (y + 1) % self.height
        return [
            self[x, prevY],
            self[prevX, y],
            self[nextX, y],
            self[x, nextY],
        ]
        .lazy.filter { $0 }.count
    }

    /// Accesses the cell at the specified position.
    @inlinable
    public subscript(x: Int, y: Int) -> Bool {
        _read { yield self.map[y][x] }
        _modify { yield &self.map[y][x] }
    }
}

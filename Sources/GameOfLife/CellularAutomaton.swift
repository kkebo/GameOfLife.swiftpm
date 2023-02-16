import BitCollections

public enum Neighborhood {
    case vonNeumann
    case moore
}

public struct CellularAutomaton {
    public let width: Int
    public let height: Int
    public let neighborhood: Neighborhood
    public private(set) var time = 0
    @usableFromInline var map: [BitArray]

    public init(width: Int, height: Int, neighborhood: Neighborhood = .moore) {
        self.width = width
        self.height = height
        self.neighborhood = neighborhood
        self.map = .init(repeating: .init(repeating: false, count: width), count: height)
    }

    public mutating func clear() {
        self.time = 0
        for i in self.map.indices {
            self.map[i].fill(with: false)
        }
    }

    public mutating func putRandomly() {
        for i in self.map.indices {
            self.map[i] = .randomBits(count: self.width)
        }
    }

    public mutating func putRPentomino() {
        self[1, 0] = true
        self[2, 0] = true
        self[0, 1] = true
        self[1, 1] = true
        self[1, 2] = true
    }

    public mutating func next() {
        self.time += 1

        var nextMap = self.map
        switch self.neighborhood {
        case .vonNeumann:
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
                    nextMap[y][x] = nextState
                }
            }
        case .moore:
            let last = self.map.endIndex - 1
            let firstLine = self.map[0]
            var line = firstLine
            var next = self.map[1]
            nextMap[0] = Self.next(of: line, prev: self.map.last!, next: next)
            for y in 1..<last {
                let prev = line
                line = next
                next = self.map[y + 1]
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
        c[0] = prev.last!
        var d = line
        d.maskingShiftRight(by: 1)
        d[d.endIndex - 1] = line[0]
        var e = line
        e.maskingShiftLeft(by: 1)
        e[0] = line.last!
        var f = next
        f.maskingShiftRight(by: 1)
        f[f.endIndex - 1] = next[0]
        var g = next
        var h = next
        h.maskingShiftLeft(by: 1)
        h[0] = next.last!

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

    @inlinable
    public subscript(x: Int, y: Int) -> Bool {
        get { self.map[y][x] }
        set { self.map[y][x] = newValue }
    }
}

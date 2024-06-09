@usableFromInline struct BitField {
    private var inner: [UInt]
    public let count: Int

    public init(count: Int) {
        precondition(count > 0)
        let (q, r) = count.quotientAndRemainder(dividingBy: UInt.bitWidth)
        self.inner = .init(repeating: 0, count: r > 0 ? q + 1 : q)
        self.count = count
    }

    public static func randomBits(count: Int) -> Self {
        precondition(count > 0)
        let (q, r) = count.quotientAndRemainder(dividingBy: UInt.bitWidth)
        let innerCount = r > 0 ? q + 1 : q
        return .init(
            inner: .init(unsafeUninitializedCapacity: innerCount) { buf, count in
                for i in 0..<innerCount {
                    buf[i] = .random(in: UInt.min...UInt.max)
                }
                count = innerCount
            },
            count: count
        )
    }

    private init(inner: [UInt], count: Int) {
        self.inner = inner
        self.count = count
    }

    public subscript(index: Int) -> Bool {
        get {
            precondition(index < self.count)
            let (q, r) = index.quotientAndRemainder(dividingBy: UInt.bitWidth)
            return self.inner[self.inner.count - 1 - q] >> r & 1 > 0
        }
        set {
            precondition(index < self.count)
            let (q, r) = index.quotientAndRemainder(dividingBy: UInt.bitWidth)
            if newValue {
                self.inner[self.inner.count - 1 - q] |= 1 << r
            } else {
                self.inner[self.inner.count - 1 - q] &= ~(1 << r)
            }
        }
    }

    public mutating func clear() {
        for i in self.inner.indices {
            self.inner[i] = 0
        }
    }
}

// Bitwise operators
extension BitField {
    public static func |= (lhs: inout Self, rhs: Self) {
        precondition(lhs.count == rhs.count)
        lhs.inner = zip(lhs.inner, rhs.inner).map(|)
    }

    public static func &= (lhs: inout Self, rhs: Self) {
        precondition(lhs.count == rhs.count)
        lhs.inner = zip(lhs.inner, rhs.inner).map(&)
    }

    public static func ^= (lhs: inout Self, rhs: Self) {
        precondition(lhs.count == rhs.count)
        lhs.inner = zip(lhs.inner, rhs.inner).map(^)
    }

    public static func | (lhs: Self, rhs: Self) -> Self {
        var newValue = lhs
        newValue |= rhs
        return newValue
    }

    public static func & (lhs: Self, rhs: Self) -> Self {
        var newValue = lhs
        newValue &= rhs
        return newValue
    }

    public static func ^ (lhs: Self, rhs: Self) -> Self {
        var newValue = lhs
        newValue ^= rhs
        return newValue
    }

    public static prefix func ~ (value: Self) -> Self {
        .init(inner: value.inner.map(~), count: value.count)
    }
}

// Bit shifting operators
extension BitField {
    public static func <<= (lhs: inout Self, rhs: Int) {
        guard rhs != 0 else { return }
        if rhs > 0 {
            lhs.shiftLeft(by: rhs)
        } else {
            lhs.shiftRight(by: -rhs)
        }
    }

    public static func >>= (lhs: inout Self, rhs: Int) {
        guard rhs != 0 else { return }
        if rhs > 0 {
            lhs.shiftRight(by: rhs)
        } else {
            lhs.shiftLeft(by: -rhs)
        }
    }

    public static func << (lhs: Self, rhs: Int) -> Self {
        var newValue = lhs
        newValue <<= rhs
        return newValue
    }

    public static func >> (lhs: Self, rhs: Int) -> Self {
        var newValue = lhs
        newValue >>= rhs
        return newValue
    }

    private mutating func shiftLeft(by amount: Int) {
        assert(amount > 0)
        precondition(amount <= UInt.bitWidth)
        let remaining = UInt.bitWidth - amount
        for i in self.inner.indices.lazy.dropLast() {
            self.inner[i] <<= amount
            self.inner[i] |= self.inner[i + 1] >> remaining
        }
        self.inner[self.inner.count - 1] <<= amount
    }

    private mutating func shiftRight(by amount: Int) {
        assert(amount > 0)
        precondition(amount <= UInt.bitWidth)
        let remaining = UInt.bitWidth - amount
        for i in self.inner.indices.lazy.dropFirst().reversed() {
            self.inner[i] >>= amount
            self.inner[i] |= self.inner[i - 1] << remaining
        }
        self.inner[0] >>= amount
        self.inner[0] &= ~(UInt.max << remaining)
    }
}

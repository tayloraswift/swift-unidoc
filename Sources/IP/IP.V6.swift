extension IP
{
    /// A native SwiftNIO ``IPv6Address`` is reference counted and resilient, and we
    /// would rather pass around an inline value type.
    @frozen public
    struct V6:Equatable, Hashable, Sendable
    {
        /// The prefix address, in big-endian byte order.
        public
        var prefix:UInt64
        /// The subnet address, in big-endian byte order.
        public
        var subnet:UInt64

        @inlinable public
        init(prefix:UInt64, subnet:UInt64)
        {
            self.prefix = prefix
            self.subnet = subnet
        }
    }
}
extension IP.V6
{
    /// Initializes an IPv6 address from a tuple of 32-bit words, with elements in big-endian
    /// byte order.
    @inlinable public
    init(storage:(UInt32, UInt32, UInt32, UInt32))
    {
        self = withUnsafeBytes(of: storage) { .copy(from: $0) }
    }

    /// Initializes an IPv6 address from a tuple of 16-bit words, with elements in big-endian
    /// byte order.
    @inlinable public
    init(storage:(UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16))
    {
        self = withUnsafeBytes(of: storage) { .copy(from: $0) }
    }

    /// Initializes an IPv6 address from 16-bit components, each in platform byte order.
    @inlinable public
    init(
        _ a:UInt16,
        _ b:UInt16,
        _ c:UInt16,
        _ d:UInt16,
        _ e:UInt16,
        _ f:UInt16,
        _ g:UInt16,
        _ h:UInt16)
    {
        self.init(storage:
        (
            a.bigEndian,
            b.bigEndian,
            c.bigEndian,
            d.bigEndian,
            e.bigEndian,
            f.bigEndian,
            g.bigEndian,
            h.bigEndian
        ))
    }
}
extension IP.V6
{
    @inlinable public
    init(v4:IP.V4)
    {
        self.init(storage: (0, 0, (0x0000_ffff as UInt32).bigEndian, v4.storage))
    }

    @inlinable public
    var v4:IP.V4?
    {
        guard
        self.prefix == 0
        else
        {
            return nil
        }

        return withUnsafeBytes(of: self.subnet)
        {
            let subnet:(UInt32, UInt32) = $0.load(as: (UInt32, UInt32).self)
            if  subnet.0 == (0x0000_ffff as UInt32).bigEndian
            {
                return .init(storage: subnet.1)
            }
            else
            {
                return nil
            }
        }
    }
}
extension IP.V6
{
    @inlinable public static
    func copy(from bytes:some RandomAccessCollection<UInt8>) -> Self
    {
        precondition(bytes.count == MemoryLayout<Self>.size)

        return withUnsafeTemporaryAllocation(
            byteCount: MemoryLayout<Self>.size,
            alignment: MemoryLayout<Self>.alignment)
        {
            $0.copyBytes(from: bytes)
            return $0.load(as: Self.self)
        }
    }
}
extension IP.V6
{
    @inlinable public static
    var zero:Self { .init(prefix: 0, subnet: 0) }

    @inlinable public static
    var ones:Self { .init(prefix: ~0, subnet: ~0) }

    /// The logical value of the address. The high byte of the first tuple element is the high
    /// byte of the first hextet.
    @inlinable public
    var value:(UInt64, UInt64)
    {
        (UInt64.init(bigEndian: self.prefix), UInt64.init(bigEndian: self.subnet))
    }
}
extension IP.V6:Comparable
{
    @inlinable public static
    func < (a:Self, b:Self) -> Bool { a.value < b.value }
}
extension IP.V6:IP.Address
{
    @inlinable public static
    var bitWidth:UInt8 { 128 }

    @inlinable public static
    func & (a:Self, b:Self) -> Self
    {
        .init(prefix: a.prefix & b.prefix, subnet: a.subnet & b.subnet)
    }

    @inlinable public static
    func / (self:Self, bits:UInt8) -> Self
    {
        let mask:Self
        let ones:UInt64 = ~0

        if  bits <= 64
        {
            mask = .init(prefix: (ones << (64 - bits)).bigEndian, subnet: 0)
        }
        else
        {
            mask = .init(prefix: ones, subnet: (ones << (128 - bits)).bigEndian)
        }

        return self & mask
    }
}
extension IP.V6:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int { 0 }

    @inlinable public
    var endIndex:Int { 8 }

    /// Returns the *i*th word of the address, in **platform** byte order.
    @inlinable public
    subscript(i:Int) -> UInt16
    {
        get
        {
            precondition(self.indices ~= i, "index out of range")

            return withUnsafeBytes(of: self)
            {
                let words:UnsafeBufferPointer<UInt16> = $0.bindMemory(to: UInt16.self)
                return .init(bigEndian: words[i])
            }
        }
        set(word)
        {
            precondition(self.indices ~= i, "index out of range")

            withUnsafeMutableBytes(of: &self)
            {
                let words:UnsafeMutableBufferPointer<UInt16> = $0.bindMemory(to: UInt16.self)
                words[i] = word.bigEndian
            }
        }
    }
}
extension IP.V6:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.lazy.map { String.init($0, radix: 16) }.joined(separator: ":")
    }
}
extension IP.V6:LosslessStringConvertible
{
    @inlinable public
    init?(_ string:some StringProtocol)
    {
        self = .zero

        var i:String.Index = string.startIndex
        var z:Int = 0
        for w:Int in 0 ..< 8
        {
            guard
            let j:String.Index = string[i...].firstIndex(of: ":")
            else
            {
                guard w == 7,
                let word:UInt16 = .init(string[i...], radix: 16)
                else
                {
                    return nil
                }

                self[w] = word
                return
            }

            guard i < j
            else
            {
                break
            }

            guard
            let word:UInt16 = .init(string[i ..< j], radix: 16)
            else
            {
                return nil
            }

            self[w] = word
            i = string.index(after: j)
            z = w + 1
        }

        var k:String.Index = string.indices.last ?? i
        for w:Int in (z ..< 8).reversed()
        {
            guard
            let j:String.Index = string[i ... k].lastIndex(of: ":")
            else
            {
                return nil
            }

            guard j < k
            else
            {
                break
            }

            guard
            let word:UInt16 = .init(string[string.index(after: j) ... k], radix: 16)
            else
            {
                return nil
            }

            self[w] = word

            guard i < j
            else
            {
                break
            }

            k = string.index(before: j)
        }
    }
}

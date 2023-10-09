extension IP
{
    @frozen public
    struct V6:Equatable, Hashable, Sendable
    {
        public
        var a:UInt16
        public
        var b:UInt16
        public
        var c:UInt16
        public
        var d:UInt16
        public
        var e:UInt16
        public
        var f:UInt16
        public
        var g:UInt16
        public
        var h:UInt16

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
            self.a = a
            self.b = b
            self.c = c
            self.d = d
            self.e = e
            self.f = f
            self.g = g
            self.h = h
        }
    }
}
extension IP.V6:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "\(a):\(b):\(c):\(d):\(e):\(f):\(g):\(h)"
    }
}
extension IP.V6:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:some StringProtocol)
    {
        guard
        var b:String.Index = description.firstIndex(of: ":"),
        let a:UInt16 = .init(description[..<b], radix: 16)
        else
        {
            return nil
        }

        b = description.index(after: b)

        guard
        var c:String.Index = description[b...].firstIndex(of: ":"),
        let b:UInt16 = .init(description[b ..< c], radix: 16)
        else
        {
            return nil
        }

        c = description.index(after: c)

        guard
        var d:String.Index = description[c...].firstIndex(of: ":"),
        let c:UInt16 = .init(description[c ..< d], radix: 16)
        else
        {
            return nil
        }

        d = description.index(after: d)

        guard
        var e:String.Index = description[d...].firstIndex(of: ":"),
        let d:UInt16 = .init(description[d ..< e], radix: 16)
        else
        {
            return nil
        }

        e = description.index(after: e)

        guard
        var f:String.Index = description[e...].firstIndex(of: ":"),
        let e:UInt16 = .init(description[e ..< f], radix: 16)
        else
        {
            return nil
        }

        f = description.index(after: f)

        guard
        var g:String.Index = description[f...].firstIndex(of: ":"),
        let f:UInt16 = .init(description[f ..< g], radix: 16)
        else
        {
            return nil
        }

        g = description.index(after: g)

        guard
        var h:String.Index = description[g...].firstIndex(of: ":"),
        let g:UInt16 = .init(description[g ..< h], radix: 16)
        else
        {
            return nil
        }

        h = description.index(after: h)

        guard
        let h:UInt16 = .init(description[h...], radix: 16)
        else
        {
            return nil
        }

        self.init(a, b, c, d, e, f, g, h)
    }
}

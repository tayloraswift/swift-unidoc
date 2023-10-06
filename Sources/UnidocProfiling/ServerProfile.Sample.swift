@frozen public
enum IP
{
}

extension IP
{
    @frozen public
    enum Address:Equatable, Hashable, Sendable
    {
        case v4(V4)
        case v6(V6)
    }
}
extension IP.Address:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case let .v4(v4):   v4.description
        case let .v6(v6):   v6.description
        }
    }
}
extension IP.Address
{
    @inlinable public static
    func v4(_ full:some StringProtocol) -> Self?
    {
        if let v4:IP.V4 = .init(full) { .v4(v4) } else { nil }
    }

    @inlinable public static
    func v6(_ full:some StringProtocol) -> Self?
    {
        if let v6:IP.V6 = .init(full) { .v6(v6) } else { nil }
    }
}
extension IP
{
    @frozen public
    struct V4:Equatable, Hashable, Sendable
    {
        public
        var a:UInt8
        public
        var b:UInt8
        public
        var c:UInt8
        public
        var d:UInt8

        @inlinable public
        init(_ a:UInt8, _ b:UInt8, _ c:UInt8, _ d:UInt8)
        {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
        }
    }
}
extension IP.V4:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "\(a).\(b).\(c).\(d)"
    }
}
extension IP.V4:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:some StringProtocol)
    {
        guard
        var b:String.Index = description.firstIndex(of: "."),
        let a:UInt8 = .init(description[..<b])
        else
        {
            return nil
        }

        b = description.index(after: b)

        guard
        var c:String.Index = description[b...].firstIndex(of: "."),
        let b:UInt8 = .init(description[b ..< c])
        else
        {
            return nil
        }

        c = description.index(after: c)

        guard
        var d:String.Index = description[c...].firstIndex(of: "."),
        let c:UInt8 = .init(description[c ..< d])
        else
        {
            return nil
        }

        d = description.index(after: d)

        guard
        let d:UInt8 = .init(description[d...])
        else
        {
            return nil
        }

        self.init(a, b, c, d)
    }
}
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

extension ServerProfile
{
    @frozen public
    struct Sample:Equatable, Sendable
    {
        public
        var ip:IP.Address?
        public
        var language:String?
        public
        var referer:String?
        public
        var agent:String?
        public
        var uri:String?

        @inlinable public
        init(ip:IP.Address? = nil,
            language:String? = nil,
            referer:String? = nil,
            agent:String? = nil,
            uri:String? = nil)
        {
            self.ip = ip
            self.language = language
            self.referer = referer
            self.agent = agent
            self.uri = uri
        }
    }
}

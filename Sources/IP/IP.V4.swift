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
        "\(self.a).\(self.b).\(self.c).\(self.d)"
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

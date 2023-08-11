extension Unidoc.Decl
{
    @frozen public
    struct Flags:Equatable, Sendable
    {
        public
        let phylum:Unidoc.Decl
        public
        let kinks:Kinks
        public
        var route:Route

        @inlinable public
        init(phylum:Unidoc.Decl, kinks:Kinks, route:Route)
        {
            self.phylum = phylum
            self.kinks = kinks
            self.route = route
        }
    }
}
extension Unidoc.Decl.Flags:RawRepresentable
{
    @inlinable public
    var rawValue:Int32
    {
        .init(self.phylum.rawValue) << 24 |
        .init(self.kinks.rawValue)  << 16 |
        .init(self.route.rawValue)
    }
    @inlinable public
    init?(rawValue:Int32)
    {
        if
            let phylum:Unidoc.Decl = .init(
                rawValue: .init(truncatingIfNeeded: rawValue >> 24)),
            let kinks:Unidoc.Decl.Kinks = .init(
                rawValue: .init(truncatingIfNeeded: rawValue >> 16)),
            let route:Unidoc.Decl.Route = .init(
                rawValue: .init(truncatingIfNeeded: rawValue))
        {
            self.init(phylum: phylum, kinks: kinks, route: route)
        }
        else
        {
            return nil
        }
    }
}

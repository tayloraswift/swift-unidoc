extension Phylum.Decl
{
    /// This type is deprecated and will gradually be replaced by ``Phylum.DeclFlags``.
    @frozen public
    struct SwiftFlags:Equatable, Sendable
    {
        public
        let phylum:Phylum.Decl
        public
        let kinks:Kinks
        public
        var route:Route

        @inlinable public
        init(phylum:Phylum.Decl, kinks:Kinks, route:Route)
        {
            self.phylum = phylum
            self.kinks = kinks
            self.route = route
        }
    }
}
extension Phylum.Decl.SwiftFlags:RawRepresentable
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
            let phylum:Phylum.Decl = .init(
                rawValue: .init(truncatingIfNeeded: rawValue >> 24)),
            let kinks:Phylum.Decl.Kinks = .init(
                rawValue: .init(truncatingIfNeeded: rawValue >> 16)),
            let route:Phylum.Decl.Route = .init(
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

extension Phylum
{
    /// This type is deprecated and will gradually be replaced by ``DeclFlags``.
    @frozen public
    struct SwiftFlags:Equatable, Sendable
    {
        public
        let phylum:Decl
        public
        let kinks:Decl.Kinks
        public
        var route:Decl.Route

        @inlinable public
        init(phylum:Decl, kinks:Decl.Kinks, route:Decl.Route)
        {
            self.phylum = phylum
            self.kinks = kinks
            self.route = route
        }
    }
}
extension Phylum.SwiftFlags:RawRepresentable
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

extension Unidoc.Decl
{
    @frozen public
    struct Flags:Equatable, Sendable
    {
        public
        let decl:Unidoc.Decl
        public
        let aperture:Aperture
        public
        var route:Route

        @inlinable public
        init(_ decl:Unidoc.Decl, aperture:Aperture, route:Route)
        {
            self.decl = decl
            self.aperture = aperture
            self.route = route
        }
    }
}
extension Unidoc.Decl.Flags:RawRepresentable
{
    @inlinable public
    var rawValue:Int32
    {
        .init(self.decl.rawValue)     << 24 |
        .init(self.aperture.rawValue) << 16 |
        .init(self.route.rawValue)
    }
    @inlinable public
    init?(rawValue:Int32)
    {
        if  let decl:Unidoc.Decl = .init(
                rawValue: .init(truncatingIfNeeded: rawValue >> 24)),
            let aperture:Unidoc.Decl.Aperture = .init(
                rawValue: .init(truncatingIfNeeded: rawValue >> 16)),
            let route:Unidoc.Decl.Route = .init(
                rawValue: .init(truncatingIfNeeded: rawValue))
        {
            self.init(decl, aperture: aperture, route: route)
        }
        else
        {
            return nil
        }
    }
}

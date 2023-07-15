extension Unidoc.Decl
{
    @frozen public
    struct Flags:Equatable, Sendable
    {
        public
        let customization:Customization
        public
        let phylum:Unidoc.Decl
        public
        var route:Route

        @inlinable public
        init(customization:Customization, phylum:Unidoc.Decl, route:Route)
        {
            self.customization = customization
            self.phylum = phylum
            self.route = route
        }
    }
}
extension Unidoc.Decl.Flags:RawRepresentable
{
    @inlinable public
    var rawValue:Int32
    {
        .init(self.customization.rawValue)  << 24 |
        .init(self.phylum.rawValue)         << 16 |

        .init(self.route.rawValue)
    }
    @inlinable public
    init?(rawValue:Int32)
    {
        if
            let customization:Unidoc.Decl.Customization = .init(
                rawValue: .init(truncatingIfNeeded: rawValue >> 24)),
            let phylum:Unidoc.Decl = .init(
                rawValue: .init(truncatingIfNeeded: rawValue >> 16)),
            let route:Unidoc.Decl.Route = .init(
                rawValue: .init(truncatingIfNeeded: rawValue))
        {
            self.init(customization: customization, phylum: phylum, route: route)
        }
        else
        {
            return nil
        }
    }
}

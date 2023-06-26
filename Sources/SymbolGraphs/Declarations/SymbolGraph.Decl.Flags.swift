import BSONDecoding
import BSONEncoding
import Unidoc

extension SymbolGraph.Decl
{
    @frozen @usableFromInline internal
    struct Flags:Equatable, Sendable
    {
        @usableFromInline internal
        let aperture:Unidoc.Decl.Aperture
        @usableFromInline internal
        let phylum:Unidoc.Decl

        @usableFromInline internal
        var route:Route

        @inlinable internal
        init(phylum:Unidoc.Decl, aperture:Unidoc.Decl.Aperture, route:Route)
        {
            self.aperture = aperture
            self.phylum = phylum
            self.route = route
        }
    }
}
extension SymbolGraph.Decl.Flags:RawRepresentable
{
    @usableFromInline internal
    var rawValue:Int32
    {
        .init(self.phylum.rawValue)   << 24 |
        .init(self.aperture.rawValue) << 16 |
        .init(self.route.rawValue)
    }
    @usableFromInline internal
    init?(rawValue:Int32)
    {
        if  let phylum:Unidoc.Decl = .init(
                rawValue: .init(truncatingIfNeeded: rawValue >> 24)),
            let aperture:Unidoc.Decl.Aperture = .init(
                rawValue: .init(truncatingIfNeeded: rawValue >> 16)),
            let route:SymbolGraph.Decl.Route = .init(
                rawValue: .init(truncatingIfNeeded: rawValue))
        {
            self.init(phylum: phylum, aperture: aperture, route: route)
        }
        else
        {
            return nil
        }
    }
}
extension SymbolGraph.Decl.Flags:BSONDecodable, BSONEncodable
{
}

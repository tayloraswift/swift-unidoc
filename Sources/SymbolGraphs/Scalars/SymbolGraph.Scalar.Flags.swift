import BSONDecoding
import BSONEncoding
import Symbols

extension SymbolGraph.Scalar
{
    @frozen @usableFromInline internal
    struct Flags:Equatable, Sendable
    {
        @usableFromInline internal
        let aperture:ScalarAperture
        @usableFromInline internal
        let phylum:ScalarPhylum

        @usableFromInline internal
        var route:Route

        @inlinable internal
        init(phylum:ScalarPhylum, aperture:ScalarAperture, route:Route)
        {
            self.aperture = aperture
            self.phylum = phylum
            self.route = route
        }
    }
}
extension SymbolGraph.Scalar.Flags:RawRepresentable
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
        if  let phylum:ScalarPhylum = .init(
                rawValue: .init(truncatingIfNeeded: rawValue >> 24)),
            let aperture:ScalarAperture = .init(
                rawValue: .init(truncatingIfNeeded: rawValue >> 16)),
            let route:SymbolGraph.Scalar.Route = .init(
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
extension SymbolGraph.Scalar.Flags:BSONDecodable, BSONEncodable
{
}

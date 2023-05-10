import BSONDecoding
import BSONEncoding
import Symbols

extension SymbolGraph.Scalar
{
    @frozen public
    struct Flags:Equatable, Sendable
    {
        public
        let aperture:ScalarAperture
        public
        let phylum:ScalarPhylum

        @inlinable public
        init(aperture:ScalarAperture, phylum:ScalarPhylum)
        {
            self.aperture = aperture
            self.phylum = phylum
        }
    }
}
extension SymbolGraph.Scalar.Flags:RawRepresentable
{
    @inlinable public
    var rawValue:Int32
    {
        .init(self.phylum.rawValue) << 8 | .init(self.aperture.rawValue)
    }
    @inlinable public
    init?(rawValue:Int32)
    {
        if  let aperture:ScalarAperture = .init(rawValue: .init(truncatingIfNeeded: rawValue)),
            let phylum:ScalarPhylum = .init(rawValue: .init(truncatingIfNeeded: rawValue >> 8))
        {
            self.init(aperture: aperture, phylum: phylum)
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

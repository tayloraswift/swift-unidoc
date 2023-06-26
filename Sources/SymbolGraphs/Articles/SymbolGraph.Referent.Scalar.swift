import BSONDecoding
import BSONEncoding

extension SymbolGraph.Referent
{
    @frozen public
    struct Scalar:RawRepresentable, Equatable, Hashable, Sendable
    {
        public
        let scalar:Int32
        public
        let length:UInt32

        @inlinable public
        init(_ scalar:Int32, length:UInt32)
        {
            self.scalar = scalar
            self.length = length
        }
    }
}
extension SymbolGraph.Referent.Scalar
{
    @inlinable public
    init(rawValue:Int64)
    {
        self.init(.init(rawValue >> 32), length: .init(truncatingIfNeeded: rawValue))
    }
    @inlinable public
    var rawValue:Int64
    {
        Int64.init(self.scalar) << 32 |
        Int64.init(self.length)
    }
}
extension SymbolGraph.Referent.Scalar:BSONDecodable, BSONEncodable
{
}

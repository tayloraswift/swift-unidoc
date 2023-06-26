import BSONDecoding
import BSONEncoding

extension SymbolGraph.Referent
{
    @frozen public
    struct Vector:Equatable, Hashable, Sendable
    {
        public
        let feature:Int32
        public
        let heir:Int32
        public
        let length:UInt32

        @inlinable public
        init(_ feature:Int32, self heir:Int32, length:UInt32)
        {
            self.feature = feature
            self.heir = heir
            self.length = length
        }
    }
}
extension SymbolGraph.Referent.Vector:RawRepresentable
{
    @inlinable public
    var rawValue:BSON.Identifier
    {
        .init(
            UInt32.init(bitPattern: self.feature),
            UInt32.init(bitPattern: self.heir),
            self.length)
    }

    @inlinable public
    init(rawValue:BSON.Identifier)
    {
        self.init(.init(bitPattern: rawValue.timestamp),
            self: .init(bitPattern: rawValue.middle),
            length: rawValue.low)
    }
}
extension SymbolGraph.Referent.Vector:BSONDecodable, BSONEncodable
{
}

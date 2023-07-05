import BSONDecoding
import BSONEncoding
import Unidoc

extension Record.Passage
{
    @frozen public
    enum Referent:Equatable, Sendable
    {
        case text(String)
        case path([Unidoc.Scalar])
    }
}
extension Record.Passage.Referent:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        switch self
        {
        case .text(let string): string.encode(to: &field)
        case .path(let vector): vector.encode(to: &field)
        }
    }
}
extension Record.Passage.Referent:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self = try bson.cast
        {
            switch $0
            {
            case .string(let utf8): return .text(    .init(bson: utf8))
            case .list(let list):   return .path(try .init(bson: list))
            case _:                 return nil
            }
        }
    }
}

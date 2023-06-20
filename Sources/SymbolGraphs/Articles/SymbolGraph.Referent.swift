import BSONDecoding
import BSONEncoding

extension SymbolGraph
{
    @frozen public
    enum Referent:Equatable, Hashable, Sendable
    {
        case unresolved(String)

        case scalar(Int32)
        case vector(Int32, self:Int32)
    }
}
extension SymbolGraph.Referent:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        switch self
        {
        case .unresolved(let codelink):
            codelink.encode(to: &field)

        case .scalar(let address):
            address.encode(to: &field)

        case .vector(let address, self: let heir):
            //  use ``Int64``, it roundtrips everywhere, and we do not sort on it.
            (heir .. address).encode(to: &field)
        }
    }
}
extension SymbolGraph.Referent:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self = try bson.cast
        {
            switch $0
            {
            case .string(let utf8):
                return .unresolved(utf8.description)

            case .int32(let int32):
                return .scalar(int32)

            case .int64(let int64):
                return .vector(.init(int64 & 0xff_ff_ff_ff), self: .init(int64 >> 32))

            default:
                break
            }

            return nil
        }
    }
}

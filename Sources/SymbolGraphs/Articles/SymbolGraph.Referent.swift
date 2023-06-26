import BSONDecoding
import BSONEncoding

extension SymbolGraph
{
    @frozen public
    enum Referent:Equatable, Hashable, Sendable
    {
        case scalar(Scalar)
        case vector(Vector)
        case unresolved(Unresolved)
    }
}
extension SymbolGraph.Referent:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        switch self
        {
        case .unresolved(let referent):
            referent.encode(to: &field)

        case .scalar(let referent):
            referent.encode(to: &field)

        case .vector(let referent):
            referent.encode(to: &field)
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
            case .document(let document):
                return .unresolved(try .init(bson: document))

            case .int64(let int64):
                return .scalar(.init(rawValue: int64))

            case .id(let int96):
                return .vector(.init(rawValue: int96))

            default:
                break
            }

            return nil
        }
    }
}

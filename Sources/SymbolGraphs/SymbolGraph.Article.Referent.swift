import BSONDecoding
import BSONEncoding
import Codelinks

extension SymbolGraph.Article
{
    @frozen public
    enum Referent:Equatable, Hashable, Sendable
    {
        case unresolved(Codelink)

        case scalar(ScalarAddress)
        case vector(ScalarAddress, self:ScalarAddress)
    }
}
extension SymbolGraph.Article.Referent:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        switch self
        {
        case .unresolved(let codelink):
            codelink.description.encode(to: &field)
        
        case .scalar(let address):
            address.value.encode(to: &field)
        
        case .vector(let address, self: let heir):
            //  use ``Int64``, it roundtrips everywhere, and we do not sort on it.
            (heir | address).encode(to: &field)
        }
    }
}
extension SymbolGraph.Article.Referent:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self = try bson.cast
        {
            switch $0
            {
            case .string(let utf8):
                if  let codelink:Codelink = .init(parsing: utf8.description)
                {
                    return .unresolved(codelink)
                }
            
            case .int32(let int32):
                if  let address:ScalarAddress = .init(exactly: int32)
                {
                    return .scalar(address)
                }
            
            case .int64(let int64):
                if  let heir:ScalarAddress = .init(exactly: .init(int64 >> 32)),
                    let address:ScalarAddress = .init(exactly: .init(int64 & 0xff_ff_ff_ff))
                {
                    return .vector(address, self: heir)
                }
            
            default:
                break
            }

            return nil
        }
    }
}

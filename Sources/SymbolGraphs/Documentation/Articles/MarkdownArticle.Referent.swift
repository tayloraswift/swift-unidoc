import BSONDecoding
import BSONEncoding
import Codelinks

extension MarkdownArticle
{
    @frozen public
    enum Referent:Equatable, Hashable, Sendable
    {
        case unresolved(Codelink)

        case scalar(ScalarAddress)
        case vector(ScalarAddress, self:ScalarAddress)
    }
}
extension MarkdownArticle.Referent:BSONEncodable
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
extension MarkdownArticle.Referent:BSONDecodable
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
                return .scalar(.init(value: int32))

            case .int64(let int64):
                return .vector(.init(value: .init(int64 & 0xff_ff_ff_ff)),
                    self: .init(value: .init(int64 >> 32)))

            default:
                break
            }

            return nil
        }
    }
}

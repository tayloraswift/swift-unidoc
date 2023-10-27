import JSON

extension GraphQL
{
    /// A GraphQL response wrapper, which contains a single field named ``data``.
    @frozen public
    struct Response<Data> where Data:JSONDecodable
    {
        public
        var data:Data

        @inlinable internal
        init(data:Data)
        {
            self.data = data
        }
    }
}
extension GraphQL.Response:JSONObjectDecodable
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case data
    }

    @inlinable public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(data: try json[.data].decode())
    }
}

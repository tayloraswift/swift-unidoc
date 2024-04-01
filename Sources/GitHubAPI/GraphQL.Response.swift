import JSON

extension GraphQL
{
    /// A GraphQL response wrapper, which contains a single field named ``data``.
    @frozen public
    struct Response<Data> where Data:JSONDecodable
    {
        public
        let data:Data
        public
        let errors:[ServerError]

        @inlinable public
        init(data:Data, errors:[ServerError])
        {
            self.data = data
            self.errors = errors
        }
    }
}
extension GraphQL.Response:JSONObjectDecodable
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case data
        case errors
    }

    @inlinable public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(data: try json[.data].decode(), errors: try json[.errors]?.decode() ?? [])
    }
}

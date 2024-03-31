import JSON

extension GraphQL
{
    /// A GraphQL response wrapper, which contains a single field named ``data``.
    @frozen public
    enum Response<Data> where Data:JSONDecodable
    {
        case success(Data)
        case failure(ServerError)
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
        if  let errors:JSON.Array = try json[.errors]?.decode()
        {
            self = .failure(.init(json: errors))
        }
        else
        {
            self = .success(try json[.data].decode())
        }
    }
}

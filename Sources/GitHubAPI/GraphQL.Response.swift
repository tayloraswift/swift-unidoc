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
        if  let data:Data = try json[.data]?.decode()
        {
            self = .success(data)
        }
        else
        {
            self = .failure(.init(json: try json[.errors].decode()))
        }
    }
}

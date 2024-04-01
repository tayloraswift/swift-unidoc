import JSON

extension GraphQL
{
    @frozen public
    struct ServerError:Equatable, Error
    {
        public
        let type:String

        @inlinable public
        init(type:String)
        {
            self.type = type
        }
    }
}
extension GraphQL.ServerError:JSONObjectDecodable
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case type
    }

    @inlinable public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(type: try json[.type].decode())
    }
}

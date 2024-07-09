import JSON

extension GitHub
{
    @frozen public
    struct Installation:Equatable, Sendable
    {
        public
        let id:Int32

        @inlinable public
        init(id:Int32)
        {
            self.id = id
        }
    }
}
extension GitHub.Installation
{
    /// There are a lot more fields in the API response, but we only need the ID.
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id
    }
}
extension GitHub.Installation:JSONObjectDecodable
{
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(id: try json[.id].decode())
    }
}

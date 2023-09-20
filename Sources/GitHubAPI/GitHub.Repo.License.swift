import JSON

extension GitHub.Repo
{
    @frozen public
    struct License:Identifiable, Equatable, Sendable
    {
        /// The SPDX identifier of the license.
        public
        var id:String
        /// The full name of the license.
        public
        var name:String

        @inlinable public
        init(id:String, name:String)
        {
            self.id = id
            self.name = name
        }
    }
}
extension GitHub.Repo.License:JSONObjectDecodable
{
    public
    enum CodingKey:String
    {
        case id = "spdx_id"
        case name
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(id: try json[.id].decode(),
            name: try json[.name].decode())
    }
}

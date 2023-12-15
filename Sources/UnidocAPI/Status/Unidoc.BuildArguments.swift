import JSON

extension Unidoc
{
    @frozen public
    struct BuildArguments
    {
        public
        let repo:String
        public
        let tag:String

        @inlinable public
        init(repo:String, tag:String)
        {
            self.repo = repo
            self.tag = tag
        }
    }
}
extension Unidoc.BuildArguments
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case repo
        case tag
    }
}
extension Unidoc.BuildArguments:JSONObjectEncodable
{
    public
    func encode(to json:inout JSON.ObjectEncoder<CodingKey>)
    {
        json[.repo] = self.repo
        json[.tag] = self.tag
    }
}
extension Unidoc.BuildArguments:JSONObjectDecodable
{
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(repo: try json[.repo].decode(), tag: try json[.tag].decode())
    }
}

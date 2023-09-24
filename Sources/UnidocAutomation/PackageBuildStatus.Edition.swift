import JSON

extension PackageBuildStatus
{
    @frozen public
    struct Edition:Equatable, Sendable
    {
        public
        let graphs:Int
        public
        let tag:String

        @inlinable public
        init(graphs:Int, tag:String)
        {
            self.graphs = graphs
            self.tag = tag
        }
    }
}
extension PackageBuildStatus.Edition
{
    @frozen public
    enum CodingKey:String
    {
        case graphs
        case tag
    }
}
extension PackageBuildStatus.Edition:JSONObjectEncodable
{
    public
    func encode(to json:inout JSON.ObjectEncoder<CodingKey>)
    {
        json[.graphs] = self.graphs
        json[.tag] = self.tag
    }
}
extension PackageBuildStatus.Edition:JSONObjectDecodable
{
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(
            graphs: try json[.graphs].decode(),
            tag: try json[.tag].decode())
    }
}

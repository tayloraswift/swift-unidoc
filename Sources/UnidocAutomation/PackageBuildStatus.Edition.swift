import JSON

extension PackageBuildStatus
{
    @frozen public
    struct Edition:Equatable, Sendable
    {
        public
        let coordinate:Int32
        public
        let graphs:Int
        public
        let tag:String

        @inlinable public
        init(coordinate:Int32, graphs:Int, tag:String)
        {
            self.coordinate = coordinate
            self.graphs = graphs
            self.tag = tag
        }
    }
}
extension PackageBuildStatus.Edition
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case coordinate
        case graphs
        case tag
    }
}
extension PackageBuildStatus.Edition:JSONObjectEncodable
{
    public
    func encode(to json:inout JSON.ObjectEncoder<CodingKey>)
    {
        json[.coordinate] = self.coordinate
        json[.graphs] = self.graphs
        json[.tag] = self.tag
    }
}
extension PackageBuildStatus.Edition:JSONObjectDecodable
{
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(coordinate: try json[.coordinate].decode(),
            graphs: try json[.graphs].decode(),
            tag: try json[.tag].decode())
    }
}

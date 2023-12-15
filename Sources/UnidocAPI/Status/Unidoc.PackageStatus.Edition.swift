import JSON
import Unidoc

extension Unidoc.PackageStatus
{
    @frozen public
    struct Edition:Equatable, Sendable
    {
        public
        let coordinate:Unidoc.Version
        public
        let graphs:Int
        public
        let tag:String

        @inlinable public
        init(coordinate:Unidoc.Version, graphs:Int, tag:String)
        {
            self.coordinate = coordinate
            self.graphs = graphs
            self.tag = tag
        }
    }
}
extension Unidoc.PackageStatus.Edition
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case coordinate
        case graphs
        case tag
    }
}
extension Unidoc.PackageStatus.Edition:JSONObjectEncodable
{
    public
    func encode(to json:inout JSON.ObjectEncoder<CodingKey>)
    {
        json[.coordinate] = self.coordinate
        json[.graphs] = self.graphs
        json[.tag] = self.tag
    }
}
extension Unidoc.PackageStatus.Edition:JSONObjectDecodable
{
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(coordinate: try json[.coordinate].decode(),
            graphs: try json[.graphs].decode(),
            tag: try json[.tag].decode())
    }
}

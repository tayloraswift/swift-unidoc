import Symbols
import JSON

extension Unidoc
{
    @frozen public
    struct BuildLabels
    {
        public
        let coordinate:Edition
        public
        let package:Symbol.Package
        public
        let repo:String
        public
        let tag:String?

        @inlinable public
        init(coordinate:Edition, package:Symbol.Package, repo:String, tag:String?)
        {
            self.coordinate = coordinate
            self.package = package
            self.repo = repo
            self.tag = tag
        }
    }
}
extension Unidoc.BuildLabels
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case coordinate
        case symbol
        case repo
        case tag
    }
}
extension Unidoc.BuildLabels:JSONObjectEncodable
{
    public
    func encode(to json:inout JSON.ObjectEncoder<CodingKey>)
    {
        json[.coordinate] = self.coordinate
        json[.symbol] = self.package
        json[.repo] = self.repo
        json[.tag] = self.tag
    }
}
extension Unidoc.BuildLabels:JSONObjectDecodable
{
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(coordinate: try json[.coordinate].decode(),
            package: try json[.symbol].decode(),
            repo: try json[.repo].decode(),
            tag: try json[.tag]?.decode())
    }
}

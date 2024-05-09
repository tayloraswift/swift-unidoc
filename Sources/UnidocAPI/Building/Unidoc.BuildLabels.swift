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
        let ref:String

        @inlinable public
        init(coordinate:Edition, package:Symbol.Package, repo:String, ref:String)
        {
            self.coordinate = coordinate
            self.package = package
            self.repo = repo
            self.ref = ref
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
        case ref
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
        json[.ref] = self.ref
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
            ref: try json[.ref].decode())
    }
}

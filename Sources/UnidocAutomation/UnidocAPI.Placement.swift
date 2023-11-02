import JSON
import Unidoc

extension UnidocAPI
{
    @frozen public
    struct Placement
    {
        public
        let edition:Unidoc.Zone

        @inlinable public
        init(edition:Unidoc.Zone)
        {
            self.edition = edition
        }
    }
}
extension UnidocAPI.Placement
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case package
        case version
    }
}
extension UnidocAPI.Placement:JSONObjectEncodable
{
    public
    func encode(to json:inout JSON.ObjectEncoder<CodingKey>)
    {
        json[.package] = self.edition.package
        json[.version] = self.edition.version
    }
}
extension UnidocAPI.Placement:JSONObjectDecodable
{
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(edition: .init(
            package: try json[.package].decode(),
            version: try json[.version].decode()))
    }
}

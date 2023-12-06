import JSON
import Unidoc

extension SwiftinitClient
{
    struct Coordinates:Sendable
    {
        var package:Unidoc.Package
        var version:Unidoc.Version

        init(package:Unidoc.Package, version:Unidoc.Version)
        {
            self.package = package
            self.version = version
        }
    }
}
extension SwiftinitClient.Coordinates:Comparable
{
    static
    func < (a:Self, b:Self) -> Bool
    {
        (a.package.rawValue, a.version.bits) < (b.package.rawValue, b.version.bits)
    }
}
extension SwiftinitClient.Coordinates:CustomStringConvertible
{
    var description:String { "(\(self.package), \(self.version))" }
}
extension SwiftinitClient.Coordinates:JSONObjectDecodable
{
    enum CodingKey:String, Sendable
    {
        case p
        case v
    }

    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(package: try json[.p].decode(), version: try json[.v].decode())
    }
}

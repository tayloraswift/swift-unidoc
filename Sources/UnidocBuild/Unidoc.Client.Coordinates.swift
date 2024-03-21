import JSON

extension Unidoc.Client
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
extension Unidoc.Client.Coordinates:Comparable
{
    static
    func < (a:Self, b:Self) -> Bool
    {
        (a.package.rawValue, a.version.bits) < (b.package.rawValue, b.version.bits)
    }
}
extension Unidoc.Client.Coordinates:CustomStringConvertible
{
    var description:String { "(\(self.package), \(self.version))" }
}
extension Unidoc.Client.Coordinates:JSONObjectDecodable
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

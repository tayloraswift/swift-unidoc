import JSON

extension SwiftinitClient
{
    struct Coordinates:Sendable
    {
        var package:Int32
        var version:Int32

        init(package:Int32, version:Int32)
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
        (a.package, a.version) < (b.package, b.version)
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

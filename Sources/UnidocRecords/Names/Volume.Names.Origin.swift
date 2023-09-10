import BSONDecoding
import BSONEncoding

extension Volume.Names
{
    @frozen public
    enum Origin:Equatable, Hashable, Sendable
    {
        /// GitHub origin. The payload starts with a slash (`/`).
        case github(String)
    }
}
extension Volume.Names.Origin
{
    @inlinable public static
    func github(_ owner:String, _ repo:String) -> Self
    {
        .github("/\(owner)/\(repo)")
    }
}
extension Volume.Names.Origin:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .github(let path): return "github.com\(path)"
        }
    }
}
extension Volume.Names.Origin:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        guard let slash:String.Index = description.firstIndex(of: "/")
        else
        {
            return nil
        }
        switch description[..<slash]
        {
        case "github.com":  self = .github(String.init(description[slash...]))
        case _:             return nil
        }
    }
}
extension Volume.Names.Origin:BSONStringDecodable, BSONStringEncodable
{
}

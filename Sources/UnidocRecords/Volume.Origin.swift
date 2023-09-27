import BSONDecoding
import BSONEncoding
import Symbols

extension Volume
{
    @frozen public
    enum Origin:Equatable, Hashable, Sendable
    {
        /// GitHub origin. The payload starts with a slash (`/`).
        case github(String)
    }
}
extension Volume.Origin
{
    @inlinable public static
    func github(_ owner:String, _ repo:String) -> Self
    {
        .github("/\(owner)/\(repo)")
    }

    public
    func blob(refname:String, file:Symbol.File) -> String?
    {
        if  case .github(let path) = self
        {
            return "https://github.com\(path)/blob/\(refname)/\(file)"
        }
        else
        {
            return nil
        }
    }
}
extension Volume.Origin:CustomStringConvertible
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
extension Volume.Origin:LosslessStringConvertible
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
extension Volume.Origin:BSONStringDecodable, BSONStringEncodable
{
}

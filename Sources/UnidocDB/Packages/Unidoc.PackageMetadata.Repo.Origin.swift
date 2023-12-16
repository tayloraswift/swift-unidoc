import BSON
import Symbols
import UnidocRecords

extension Unidoc.PackageMetadata.Repo
{
    @frozen public
    enum Origin:Equatable, Hashable, Sendable
    {
        /// GitHub origin. The payload starts with a slash (`/`).
        case github(String)
    }
}
extension Unidoc.PackageMetadata.Repo.Origin
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
            "https://github.com\(path)/blob/\(refname)/\(file)"
        }
        else
        {
            nil
        }
    }
}
extension Unidoc.PackageMetadata.Repo.Origin:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .github(let path): "github.com\(path)"
        }
    }
}
extension Unidoc.PackageMetadata.Repo.Origin:LosslessStringConvertible
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
extension Unidoc.PackageMetadata.Repo.Origin:BSONStringDecodable, BSONStringEncodable
{
}

import BSONDecoding
import BSONEncoding
import Symbols
import UnidocRecords

extension Realm.Package.Repo
{
    @frozen public
    enum Origin:Equatable, Hashable, Sendable
    {
        /// GitHub origin. The payload starts with a slash (`/`).
        case github(String)
    }
}
extension Realm.Package.Repo.Origin
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
extension Realm.Package.Repo.Origin:CustomStringConvertible
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
extension Realm.Package.Repo.Origin:LosslessStringConvertible
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
extension Realm.Package.Repo.Origin:BSONStringDecodable, BSONStringEncodable
{
}

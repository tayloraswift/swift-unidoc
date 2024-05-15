import UnidocRecords

extension Unidoc
{
    @frozen public
    enum PackageRights:Comparable, Sendable
    {
        case reader
        case editor
        case owner
    }
}
extension Unidoc.PackageRights
{
    @inlinable public static
    func of(account:Unidoc.Account,
        access:[Unidoc.Account],
        owner:Unidoc.Account) -> Unidoc.PackageRights
    {
        if  account == owner
        {
            return .owner
        }
        else if access.contains(owner)
        {
            return .editor
        }
        else
        {
            return .reader
        }
    }
}

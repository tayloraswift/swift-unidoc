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
        rulers:Unidoc.PackageRulers) -> Unidoc.PackageRights
    {
        if  case account? = rulers.owner
        {
            return .owner
        }
        else if let owner:Unidoc.Account = rulers.owner, access.contains(owner)
        {
            return .owner
        }
        else if rulers.editors.contains(account)
        {
            return .editor
        }
        else
        {
            return .reader
        }
    }
}

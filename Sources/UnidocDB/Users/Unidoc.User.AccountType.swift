import UnidocRecords

extension Unidoc.User
{
    @frozen @usableFromInline internal
    enum AccountType:Int64
    {
        case machine = 0
        case github = 1
    }
}
extension Unidoc.User.AccountType
{
    @inlinable internal
    subscript(scalar:Int32) -> Int64
    {
        .init(scalar) | (self.rawValue << 32)
    }
}

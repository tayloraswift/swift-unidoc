import UnidocRecords

extension Unidex.User
{
    @frozen @usableFromInline internal
    enum AccountType:Int64
    {
        case machine = 0
        case github = 1
    }
}
extension Unidex.User.AccountType
{
    @inlinable internal
    subscript(scalar:Int32) -> Int64
    {
        .init(scalar) | (self.rawValue << 32)
    }
}

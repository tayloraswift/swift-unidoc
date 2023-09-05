extension Account.ID
{
    @frozen @usableFromInline internal
    enum Namespace:Int64
    {
        case machine = 0
        case github = 1
    }
}
extension Account.ID.Namespace
{
    @inlinable internal
    subscript(scalar:Int32) -> Int64
    {
        .init(scalar) | (self.rawValue << 32)
    }
}

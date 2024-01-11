extension Unidoc
{
    struct LinkerIndex<Pointee>:Equatable, Hashable, Sendable
        where Pointee:Unidoc.LinkerIndexable
    {
        let ordinal:Int

        init(ordinal:Int)
        {
            self.ordinal = ordinal
        }
    }
}
extension Unidoc.LinkerIndex:Comparable
{
    static
    func < (a:Self, b:Self) -> Bool { a.ordinal < b.ordinal }
}
extension Unidoc.LinkerIndex
{
    func `in`(_ edition:Unidoc.Edition) -> Unidoc.Group
    {
        Pointee.type.id(self.ordinal, in: edition)
    }
}

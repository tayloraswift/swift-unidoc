extension Unidoc.ExtensionBody
{
    struct ID:Equatable, Hashable, Sendable
    {
        let index:Int

        init(index:Int)
        {
            self.index = index
        }
    }
}
extension Unidoc.ExtensionBody.ID:Comparable
{
    static
    func < (a:Self, b:Self) -> Bool { a.index < b.index }
}
extension Unidoc.ExtensionBody.ID
{
    func `in`(_ edition:Unidoc.Edition) -> Unidoc.Group.ID
    {
        Unidoc.GroupType.extension.id(self.index, in: edition)
    }
}

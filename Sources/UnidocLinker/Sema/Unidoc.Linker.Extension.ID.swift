extension Unidoc.Linker.Extension
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
extension Unidoc.Linker.Extension.ID:Comparable
{
    static
    func < (a:Self, b:Self) -> Bool { a.index < b.index }
}

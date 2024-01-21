import UnidocRecords

extension Unidoc.Linker.Tables
{
    /// A type that can generate ``Unidoc.Group`` identifiers.
    struct Next
    {
        private
        let base:Unidoc.Edition
        private
        var next:Counter

        init(base:Unidoc.Edition)
        {
            self.base = base
            self.next = .init()
        }
    }
}
extension Unidoc.Linker.Tables.Next
{
    mutating
    func callAsFunction(_ type:Unidoc.GroupType) -> Unidoc.Group
    {
        type.id(self.next(), in: self.base)
    }

    @available(*, deprecated)
    mutating
    func polygon() -> Unidoc.Group
    {
        Unidoc.GroupType.polygon.id(self.next(), in: self.base)
    }

    @available(*, deprecated)
    mutating
    func topic() -> Unidoc.Group
    {
        Unidoc.GroupType.topic.id(self.next(), in: self.base)
    }
}

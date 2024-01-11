import UnidocRecords

extension Unidoc.Linker.Tables
{
    struct Next
    {
        private
        var polygons:Counter
        private
        var topics:Counter
        private
        let base:Unidoc.Edition

        init(base:Unidoc.Edition)
        {
            self.polygons = .init()
            self.topics = .init()
            self.base = base
        }
    }
}
extension Unidoc.Linker.Tables.Next
{
    mutating
    func polygon() -> Unidoc.Group
    {
        Unidoc.GroupType.polygon.id(self.polygons(), in: self.base)
    }

    mutating
    func topic() -> Unidoc.Group
    {
        Unidoc.GroupType.topic.id(self.topics(), in: self.base)
    }
}

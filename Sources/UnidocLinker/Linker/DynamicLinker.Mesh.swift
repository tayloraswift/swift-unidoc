import JSON
import UnidocRecords

extension DynamicLinker
{
    @frozen public
    struct Mesh:~Copyable
    {
        public
        var vertices:[Volume.Vertex]
        public
        var groups:[Volume.Group]
        public
        var trees:[Volume.TypeTree]
        public
        var index:JSON
        public
        var meta:Volume.Meta.LinkDetails

        init(vertices:[Volume.Vertex],
            groups:[Volume.Group],
            trees:[Volume.TypeTree],
            index:JSON,
            meta:Volume.Meta.LinkDetails)
        {
            self.vertices = vertices
            self.groups = groups
            self.trees = trees
            self.index = index
            self.meta = meta
        }
    }
}

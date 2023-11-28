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
        var index:JSON
        public
        var trees:[Volume.TypeTree]
        public
        var tree:[Volume.Noun]

        init(vertices:[Volume.Vertex],
            groups:[Volume.Group],
            index:JSON,
            trees:[Volume.TypeTree],
            tree:[Volume.Noun])
        {
            self.vertices = vertices
            self.groups = groups
            self.index = index
            self.trees = trees
            self.tree = tree
        }
    }
}

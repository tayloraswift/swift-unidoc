import JSON
import Unidoc

@frozen public
struct Volume:~Copyable
{
    public
    var latest:Unidoc.Edition?

    public
    var vertices:[Vertex]
    public
    var groups:[Group]
    public
    var index:JSON
    public
    var trees:[TypeTree]
    public
    var meta:Meta

    @inlinable public
    init(latest:Unidoc.Edition?,
        vertices:[Vertex],
        groups:[Group],
        index:JSON,
        trees:[TypeTree],
        meta:Meta)
    {
        self.latest = latest

        self.vertices = vertices
        self.groups = groups
        self.index = index
        self.trees = trees
        self.meta = meta
    }
}
extension Volume
{
    @inlinable public
    var edition:Unidoc.Edition { self.meta.id }
}
extension Volume
{
    @inlinable public
    var id:VolumeIdentifier { self.meta.symbol }
}
extension Volume
{
    @inlinable public
    var search:SearchIndex<VolumeIdentifier>
    {
        .init(id: self.id, json: self.index)
    }

    public
    func sitemap() -> Realm.Sitemap
    {
        var elements:Realm.Sitemap.Elements = []
        //  Reverse, because C modules tend to appear in the beginning of the list, and
        //  we want to prioritize Swift modules.
        for vertex:Vertex in self.vertices.reversed()
        {
            switch vertex
            {
            case .culture(let vertex):  elements.append(vertex.shoot)
            case .article(let vertex):  elements.append(vertex.shoot)
            case .decl(let vertex):     elements.append(vertex.shoot)
            case .file:                 continue
            case .foreign:              continue
            case .global:               continue
            }
        }

        return .init(id: self.meta.symbol.package, elements: elements)
    }
}
